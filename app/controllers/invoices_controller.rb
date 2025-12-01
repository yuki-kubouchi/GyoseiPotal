class InvoicesController < ApplicationController
  require 'prawn'
  require 'prawn/table'
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :download]

  def index
    @q = params[:q].to_s.strip
    @status = params[:status].to_s.strip
    @customer_id = params[:customer_id].to_s.strip
    @application_id = params[:application_id].to_s.strip
    @sort = params[:sort].presence_in(%w[issue_date due_date total status]) || "issue_date"
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
        "invoices.invoice_number LIKE :q OR customers.name LIKE :q OR applications.title LIKE :q",
        q: like
      )
    end

    scope = scope.where(status: Invoice.statuses[@status] || @status) if @status.present?
    scope = scope.where(customer_id: @customer_id) if @customer_id.present?
    scope = scope.where(application_id: @application_id) if @application_id.present?
    scope = scope.where('issue_date >= ?', @start_date) if @start_date
    scope = scope.where('issue_date <= ?', @end_date) if @end_date

    order_sql = if @sort.present?
      { @sort => @direction }
    else
      { issue_date: :desc, id: :desc }
    end
    
    @invoices = scope.order(order_sql).page(params[:page]).per(@per)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "請求書_#{@invoice.invoice_number}",
               template: 'invoices/show_pdf',
               locals: { invoice: @invoice },
               encoding: "UTF-8"
      end
    end
  end

  def new
    @invoice = Invoice.new(
      issue_date: Date.current,
      due_date: Date.current + 30.days,
      status: :draft,
      tax_rate: 10.0,
      customer_id: params[:customer_id],
      application_id: params[:application_id]
    )
    # before_validation による自動採番を呼び出すために valid? を実行していたが、
    # その副作用で空のフォームにバリデーションエラーが表示されてしまう。
    # private メソッドを直接呼び出して請求書番号を生成する（エラーを出さない）。
    @invoice.send(:generate_invoice_number)
    1.times { @invoice.invoice_items.build } if @invoice.invoice_items.empty?
  end

  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      redirect_to @invoice, notice: '請求書を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: '請求書を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_url, notice: '請求書を削除しました。', status: :see_other
  end

  def download
    send_data WickedPdf.new.pdf_from_string(
      render_to_string(template: 'invoices/show_pdf', locals: { invoice: @invoice }),
      encoding: "UTF-8"
    ),
    filename: "請求書_#{@invoice.invoice_number}.pdf",
    type: 'application/pdf',
    disposition: 'attachment'
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :application_id, :customer_id, :invoice_number, :issue_date, :due_date,
      :status, :tax_rate, :notes,
      invoice_items_attributes: [:id, :description, :quantity, :unit_price, :amount, :_destroy]
    )
  end

  def number_format(number)
    number.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def sanitize_for_pdf(text)
    # Remove non-ASCII characters and replace with placeholder
    text.to_s.encode('ASCII', invalid: :replace, undef: :replace, replace: '?')
  end

  def generate_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: [40, 40, 40, 40])
    
    # Use default font (no custom fonts due to LFS issues)
    # Japanese text will be displayed in Helvetica placeholder format
    pdf.font 'Helvetica'
    
    # ヘッダー
    pdf.text "Invoice", size: 24, align: :center, style: :bold
    pdf.move_down 30
    
    # Basic Information
    pdf.text "Invoice Number: #{invoice.invoice_number}", size: 12
    pdf.text "Issue Date: #{invoice.issue_date}", size: 12
    pdf.text "Due Date: #{invoice.due_date}", size: 12
    pdf.move_down 20
    
    # Customer Information
    pdf.text "CUSTOMER INFORMATION", size: 12, style: :bold
    pdf.text "Company: #{sanitize_for_pdf(invoice.customer&.name)}", size: 12
    pdf.text "Attention:", size: 12
    pdf.move_down 20
    
    # Invoice Items Title
    pdf.text "INVOICE DETAILS", size: 12, style: :bold
    pdf.move_down 10
    
    # Invoice Items Table
    items = [["Description", "Quantity", "Unit Price", "Amount"]]
    invoice.invoice_items.each do |item|
      items << [
        sanitize_for_pdf(item.description),
        item.quantity.to_s,
        "#{number_format(item.unit_price)}",
        "#{number_format(item.amount)}"
      ]
    end
    
    pdf.table items, width: 500, cell_style: { size: 10, border_width: 1, padding: 8 } do
      row(0).font_style = :bold
      row(0).background_color = "f0f0f0"
      columns(1..3).align = :right
      self.row_colors = ["ffffff", "f8f8f8"]
      self.header = true
    end
    
    pdf.move_down 20
    
    # Totals
    pdf.text "Subtotal: #{number_format(invoice.subtotal)}", align: :right
    pdf.text "Tax (#{invoice.tax_rate}%): #{number_format(invoice.tax_amount)}", align: :right
    pdf.text "Total: #{number_format(invoice.total)}", align: :right, size: 14, style: :bold
    
    # Notes
    if invoice.notes.present?
      pdf.move_down 20
      pdf.text "NOTES", size: 12, style: :bold
      pdf.text sanitize_for_pdf(invoice.notes), size: 12
    end
    
    # Footer
    pdf.repeat(:all) do
      pdf.bounding_box([0, 30], width: 540, height: 20) do
        pdf.text "Issued: #{invoice.issue_date}", align: :right, size: 10
      end
    end
    
    pdf.render
  end
end
