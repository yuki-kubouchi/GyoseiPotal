class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update destroy]

  def index
    @q = params[:q].to_s.strip
    @status = params[:status].to_s.strip
    @customer_id = params[:customer_id].to_s.strip
    @application_id = params[:application_id].to_s.strip
    @sort = params[:sort].presence_in(%w[issued_on amount_yen status]) || "issued_on"
    @direction = params[:direction].presence_in(%w[asc desc]) || "desc"
    @start_date = begin
      Date.parse(params[:start_date]) if params[:start_date].present?
    rescue ArgumentError
      nil
    end
    @end_date = begin
      Date.parse(params[:end_date]) if params[:end_date].present?
    rescue ArgumentError
      nil
    end
    @per = params[:per].to_i
    @per = 10 if @per <= 0 || @per > 100

    scope = Invoice.includes(:customer, :application).all

    if @q.present?
      like = "%#{@q}%"
      scope = scope.joins(:customer, :application).where(
        "customers.code LIKE ? OR customers.name LIKE ? OR applications.title LIKE ?",
        like, like, like
      )
    end

    scope = scope.where(status: Invoice.statuses[@status] || @status) if @status.present?
    scope = scope.where(customer_id: @customer_id) if @customer_id.present?
    scope = scope.where(application_id: @application_id) if @application_id.present?
    scope = scope.where('issued_on >= ?', @start_date) if @start_date
    scope = scope.where('issued_on <= ?', @end_date) if @end_date

    # apply sorting
    order_sql = if @sort.present?
      Arel.sql("#{@sort} #{@direction}")
    else
      { issued_on: :desc, id: :desc }
    end
    @invoices = scope.order(order_sql).page(params[:page]).per(@per)

    respond_to do |format|
      format.html
      format.csv do
        require 'csv'
        headers = [
          'customer_code','customer_name','application_title','amount_yen','issued_on','status'
        ]
        csv = CSV.generate(write_headers: true, headers: headers) do |rows|
          scope.find_each do |inv|
            rows << [
              inv.customer&.code,
              inv.customer&.name,
              inv.application&.title,
              inv.amount_yen,
              inv.issued_on,
              inv.status
            ]
          end
        end
        send_data csv, filename: "invoices-#{Time.current.strftime('%Y%m%d-%H%M%S')}.csv"
      end
    end
  end

  def show; end

  def new
    @invoice = Invoice.new(issued_on: Date.current, status: :issued)
    @invoice.customer_id = params[:customer_id] if params[:customer_id].present?
    @invoice.application_id = params[:application_id] if params[:application_id].present?
  end

  def edit; end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      redirect_to @invoice, notice: '請求を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: '請求を更新しました。', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy!
    redirect_to invoices_path, notice: '請求を削除しました。', status: :see_other
  end

  private
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:customer_id, :application_id, :amount_yen, :issued_on, :status)
  end
end
