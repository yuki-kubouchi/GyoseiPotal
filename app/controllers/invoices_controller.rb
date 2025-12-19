class InvoicesController < ApplicationController
  require 'prawn'
  require 'prawn/table'
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :download, :download_estimate, :download_receipt]

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
      # PostgreSQLでは大文字小文字を区別しない検索にILIKEを使用
      like_operator = postgresql? ? 'ILIKE' : 'LIKE'
      scope = scope.joins(:customer, :application).where(
        "invoices.invoice_number #{like_operator} :q OR customers.name #{like_operator} :q OR applications.title #{like_operator} :q",
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
    @office = OfficeSetting.instance
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "請求書_#{@invoice.invoice_number}",
               template: 'invoices/show_pdf',
               locals: { invoice: @invoice, office: @office },
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
      # 金額を更新
      @invoice.update_columns(
        subtotal: @invoice.calculate_subtotal,
        tax_amount: @invoice.calculate_tax_amount,
        total: @invoice.calculate_total
      )
      redirect_to @invoice, notice: '請求書を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @invoice.update(invoice_params)
      # 金額を更新
      @invoice.update_columns(
        subtotal: @invoice.calculate_subtotal,
        tax_amount: @invoice.calculate_tax_amount,
        total: @invoice.calculate_total
      )
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
    begin
      Rails.logger.info "=== Invoice PDF Download (Prawn) ==="
      Rails.logger.info "Invoice ID: #{@invoice.id}"
      
      pdf_content = helpers.generate_invoice_pdf(@invoice)
      
      send_data pdf_content,
                filename: "請求書_#{@invoice.invoice_number}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    rescue => e
      Rails.logger.error "Invoice PDF generation error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(10).join("\n")
      raise
    end
  end
  
  def download_estimate
    begin
      Rails.logger.info "=== PDF Download (Prawn) ==="
      Rails.logger.info "Invoice ID: #{@invoice.id}"
      
      pdf_content = helpers.generate_estimate_pdf(@invoice)
      
      send_data pdf_content,
                filename: "見積書_#{@invoice.invoice_number}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    rescue => e
      Rails.logger.error "PDF generation error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(10).join("\n")
      raise
    end
  end
  
  def download_receipt
    begin
      Rails.logger.info "=== Receipt PDF Download (Prawn) ==="
      Rails.logger.info "Invoice ID: #{@invoice.id}"
      
      pdf_content = helpers.generate_receipt_pdf(@invoice)
      
      send_data pdf_content,
                filename: "領収書_#{@invoice.invoice_number}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    rescue => e
      Rails.logger.error "Receipt PDF generation error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(10).join("\n")
      raise
    end
  end

  private

  def set_invoice
    @invoice = Invoice.eager_load(:customer, :application, :invoice_items).find(params[:id])
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
    
    # 日本語フォントの設定
    pdf.font_families.update(
      'IPAGothic' => {
        normal: 'ipag.ttf',
        bold: 'ipag.ttf',
        italic: 'ipag.ttf',
        bold_italic: 'ipag.ttf'
      }
    )
    
    begin
      pdf.font 'IPAGothic'
    rescue Prawn::Errors::UnknownFont
      # 日本語フォントが利用できない場合はデフォルトのフォントを使用
      pdf.font 'Helvetica'
    end
    
    # ヘッダー
    pdf.text "請求書", size: 24, align: :center, style: :bold
    pdf.move_down 30
    
    # 基本情報
    pdf.text "請求書番号: #{invoice.invoice_number}", size: 12
    pdf.text "発行日: #{invoice.issue_date.strftime('%Y年%m月%d日')}", size: 12
    pdf.text "支払期日: #{invoice.due_date.strftime('%Y年%m月%d日')}", size: 12
    pdf.move_down 30
    
    # 請求先情報と発行者情報を横並びに表示
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      # 左側: 請求先情報
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2 - 15) do
        pdf.stroke_bounds
        pdf.pad(10) do
          pdf.text "請求先", size: 14, style: :bold
          pdf.move_down 5
          
          if invoice.customer&.company_name.present?
            pdf.text "#{invoice.customer.company_name} 御中", size: 12
          else
            pdf.text "#{invoice.customer&.name} 様", size: 12
          end
          
          if invoice.application.present?
            pdf.move_down 5
            pdf.text "案件: #{invoice.application.title}", size: 10
          end
        end
      end
      
      # 右側: 発行者情報
      pdf.bounding_box([pdf.bounds.width / 2 + 5, pdf.cursor + pdf.bounds.absolute_top - pdf.y], 
                      width: pdf.bounds.width / 2 - 15) do
        pdf.stroke_bounds
        pdf.pad(10) do
          pdf.text "発行者", size: 14, style: :bold
          pdf.move_down 5
          
          pdf.text "行政ポータル事務所", size: 12
          pdf.text "〒100-0000", size: 10
          pdf.text "東京都千代田区〇〇1-2-3", size: 10
          pdf.move_down 5
          pdf.text "TEL: 03-1234-5678", size: 10
          pdf.text "FAX: 03-1234-5679", size: 10
          pdf.text "Email: info@gyoseipotal.jp", size: 10
        end
      end
    end
    
    pdf.move_down 30
    
    # 明細タイトル
    pdf.text "明細", size: 14, style: :bold
    pdf.move_down 10
    
    # 明細テーブル
    items = [["品名", "数量", "単価", "金額"]]
    invoice.invoice_items.each do |item|
      items << [
        item.description.to_s,
        item.quantity.to_s,
        number_format(item.unit_price.to_i).to_s,
        number_format(item.amount.to_i).to_s
      ]
    end
    
    pdf.table items, width: 500, cell_style: { size: 10, border_width: 1, padding: 8 } do |table|
      table.row(0).font_style = :bold
      table.row(0).background_color = "f0f0f0"
      table.columns(1..3).align = :right
      table.row_colors = ["ffffff", "f8f8f8"]
      table.header = true
    end
    
    pdf.move_down 20
    
    # 合計
    pdf.text "小計: #{number_format(invoice.subtotal.to_i)} 円", align: :right
    pdf.text "消費税 (#{invoice.tax_rate}%): #{number_format(invoice.tax_amount.to_i)} 円", align: :right
    pdf.text "合計: #{number_format(invoice.total.to_i)} 円", align: :right, size: 14, style: :bold
    
    # 備考
    if invoice.notes.present?
      pdf.move_down 20
      pdf.text "備考", size: 12, style: :bold
      pdf.text invoice.notes.to_s, size: 12
    end
    
    # フッター
    pdf.repeat(:all) do
      pdf.bounding_box([0, 30], width: 540, height: 20) do
        pdf.text "発行日: #{invoice.issue_date.strftime('%Y年%m月%d日')}", align: :right, size: 10
      end
    end
    
    pdf.render
  end
end
