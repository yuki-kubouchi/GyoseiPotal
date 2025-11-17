class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]

  # GET /customers or /customers.json
  def index
    @q = params[:q].to_s.strip
    @status = params[:status].to_s.strip
    @sort = params[:sort].presence_in(%w[code name status]) || "code"
    @direction = params[:direction].presence_in(%w[asc desc]) || "asc"

    scope = Customer.all

    if @q.present?
      like = "%#{@q}%"
      scope = scope.where("code LIKE ? OR name LIKE ?", like, like)
    end

  # POST /customers/import
  def import
    file = params[:file]
    if file.blank?
      redirect_to customers_path, alert: "CSVファイルを選択してください。"
      return
    end
    require 'csv'
    count = 0
    CSV.foreach(file.path, headers: true, return_headers: false, encoding: "UTF-8") do |row|
      attrs = row.to_h.slice("code","name","company_name","kana","email","phone","address","notes","status")
      next if attrs["code"].blank?
      # allow status to be enum key or integer
      s = attrs["status"]
      attrs["status"] = Customer.statuses[s] || s
      customer = Customer.where(code: attrs["code"]).first_or_initialize
      customer.assign_attributes(attrs)
      if customer.save
        count += 1
      end
    end
    redirect_to customers_path, notice: "CSVインポート完了: #{count}件"
  end

    if @status.present?
      # accept enum key or integer
      status_value = Customer.statuses[@status] || @status
      scope = scope.where(status: status_value)
    end

    scope = scope.order(Arel.sql("#{@sort} #{@direction}"))

    @customers = scope.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.csv do
        require 'csv'
        headers = ["code","name","company_name","kana","email","phone","address","notes","status"]
        csv = CSV.generate(write_headers: true, headers: headers) do |rows|
          scope.find_each do |c|
            rows << [c.code, c.name, c.company_name, c.kana, c.email, c.phone, c.address, c.notes, c.status]
          end
        end
        send_data csv, filename: "customers-#{Time.current.strftime('%Y%m%d-%H%M%S')}.csv"
      end
    end
  end

  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, notice: "Customer was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:code, :name, :company_name, :kana, :email, :phone, :address, :notes, :status)
    end
end
