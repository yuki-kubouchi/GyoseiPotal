class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[ show edit update destroy purge_document ]

  # GET /applications or /applications.json
  def index
    @q = params[:q].to_s.strip
    @status = params[:status].to_s.strip
    @customer_id = params[:customer_id].to_s.strip
    @due = params[:due].to_s.strip.presence_in(%w[overdue soon])
    @sort = params[:sort].presence_in(%w[title status due_on]) || "due_on"
    @direction = params[:direction].presence_in(%w[asc desc]) || "asc"
    @per = params[:per].to_i
    @per = 10 if @per <= 0 || @per > 100
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

    scope = Application.includes(:customer).all

    if @q.present?
      like = "%#{@q}%"
      scope = scope.where("applications.title LIKE ?", like)
    end

  # POST /applications/import
  def import
    file = params[:file]
    if file.blank?
      redirect_to applications_path, alert: "CSVファイルを選択してください。"
      return
    end
    require 'csv'
    count = 0
    CSV.foreach(file.path, headers: true, return_headers: false, encoding: "UTF-8") do |row|
      h = row.to_h
      # Expected headers: customer_code,title,status,due_on,notes
      customer_code = h["customer_code"].to_s.strip
      next if customer_code.blank?
      customer = Customer.find_by(code: customer_code)
      next unless customer
      attrs = {
        customer_id: customer.id,
        title: h["title"],
        status: (Application.statuses[h["status"]] || h["status"]),
        due_on: h["due_on"],
        notes: h["notes"]
      }
      app = Application.new(attrs)
      count += 1 if app.save
    end
    redirect_to applications_path, notice: "CSVインポート完了: #{count}件"
  end

    if @status.present?
      status_value = Application.statuses[@status] || @status
      scope = scope.where(status: status_value)
    end

    if @customer_id.present?
      scope = scope.where(customer_id: @customer_id)
    end

    scope = scope.where('due_on >= ?', @start_date) if @start_date
    scope = scope.where('due_on <= ?', @end_date) if @end_date

    if @due.present?
      today = Date.current
      case @due
      when 'overdue'
        scope = scope.where.not(due_on: nil).where('due_on < ?', today).where.not(status: Application.statuses[:approved])
      when 'soon'
        scope = scope.where.not(due_on: nil).where('due_on >= ? AND due_on <= ?', today, today + 7.days).where.not(status: Application.statuses[:approved])
      end
    end

    scope = scope.order(Arel.sql("#{@sort} #{@direction}"))

    @applications = scope.page(params[:page]).per(@per)

    respond_to do |format|
      format.html
      format.csv do
        require 'csv'
        headers = ["customer_code","title","status","due_on","notes"]
        csv = CSV.generate(write_headers: true, headers: headers) do |rows|
          scope.includes(:customer).find_each do |a|
            rows << [a.customer&.code, a.title, a.status, a.due_on, a.notes]
          end
        end
        send_data csv, filename: "applications-#{Time.current.strftime('%Y%m%d-%H%M%S')}.csv"
      end
    end
  end

  # GET /applications/1 or /applications/1.json
  def show
    @invoices = @application.invoices.includes(:customer).order(issued_on: :desc, id: :desc)
    @invoices_total_yen = @invoices.sum(:amount_yen)
    @issued_total_yen = @invoices.where(status: Invoice.statuses[:issued]).sum(:amount_yen) if defined?(Invoice)
    @paid_total_yen = @invoices.where(status: Invoice.statuses[:paid]).sum(:amount_yen) if defined?(Invoice)
    @outstanding_total_yen = (@issued_total_yen.to_i - @paid_total_yen.to_i)
    @destinations = Destination.order(:name)
  end

  # GET /applications/new
  def new
    @application = Application.new
    if params[:customer_id].present?
      @application.customer_id = params[:customer_id]
    end
  end

  # GET /applications/1/edit
  def edit
  end

  # POST /applications or /applications.json
  def create
    @application = Application.new(application_params)

    respond_to do |format|
      if @application.save
        format.html { redirect_to @application, notice: "Application was successfully created." }
        format.json { render :show, status: :created, location: @application }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /applications/1 or /applications/1.json
  def update
    respond_to do |format|
      if @application.update(application_params)
        format.html { redirect_to @application, notice: "Application was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @application }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applications/1 or /applications/1.json
  def destroy
    @application.destroy!

    respond_to do |format|
      format.html { redirect_to applications_path, notice: "Application was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # DELETE /applications/:id/documents/:attachment_id
  def purge_document
    attachment = @application.documents.attachments.find_by(id: params[:attachment_id])
    if attachment
      attachment.purge
      redirect_to @application, notice: "添付ファイルを削除しました。"
    else
      redirect_to @application, alert: "添付ファイルが見つかりません。"
    end
  end

  # PATCH /applications/:id/documents/:attachment_id/info
  def update_document_info
    attachment = @application.documents.attachments.find_by(id: params[:attachment_id])
    unless attachment
      return redirect_to @application, alert: "添付ファイルが見つかりません。"
    end
    blob = attachment.blob
    meta = (blob.metadata || {}).dup

    # Prefer destination_id; fallback to free text 'destination'
    dest_id = params[:destination_id].to_s.strip
    if dest_id.present?
      dest = Destination.find_by(id: dest_id)
      if dest
        meta['destination_id'] = dest.id
        meta['destination_name'] = dest.name
        meta.delete('destination') # cleanup legacy
      else
        meta.delete('destination_id')
        meta.delete('destination_name')
      end
    else
      # If no id provided, allow clearing or legacy text update
      legacy_text = params[:destination].to_s.strip
      if legacy_text.present?
        meta['destination'] = legacy_text
        meta.delete('destination_id')
        meta.delete('destination_name')
      else
        meta.delete('destination')
        meta.delete('destination_id')
        meta.delete('destination_name')
      end
    end

    blob.metadata = meta
    if blob.save
      redirect_to @application, notice: "申請先を更新しました。"
    else
      redirect_to @application, alert: "申請先の更新に失敗しました。"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def application_params
      params.require(:application).permit(:customer_id, :title, :status, :due_on, :notes, documents: [])
    end
  end
