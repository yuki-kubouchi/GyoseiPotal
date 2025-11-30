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
        send_data generate_pdf(@invoice),
                  filename: "請求書_#{@invoice.invoice_number}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
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
    @invoice.valid? # 請求書番号を生成するためにバリデーションを実行
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
    send_data generate_pdf(@invoice),
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

  def generate_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: [40, 40, 40, 40])
    
    # 日本語フォントの設定
    font_path = Rails.root.join('app', 'assets', 'fonts')
    pdf.font_families.update(
      'Noto Sans JP' => {
        normal: font_path.join('NotoSansJP-Regular.ttf').to_s,
        bold: font_path.join('NotoSansJP-Bold.ttf').to_s
      }
    )
    pdf.font 'Noto Sans JP'
    
    # ヘッダー
    pdf.text "請求書", size: 24, align: :center, style: :bold
    pdf.move_down 30
    
    # 基本情報
    pdf.text "請求番号: #{invoice.invoice_number}", size: 12
    pdf.text "発行日: #{invoice.issue_date}", size: 12
    pdf.text "お支払い期限: #{invoice.due_date}", size: 12
    pdf.move_down 20
    
    # 顧客情報
    pdf.text "【お客様情報】", size: 12, style: :bold
    pdf.text "会社名: #{invoice.customer&.name}", size: 12
    pdf.text "担当者様", size: 12
    pdf.move_down 20
    
    # 明細タイトル
    pdf.text "【ご請求内容】", size: 12, style: :bold
    pdf.move_down 10
    
    # 明細テーブル
    items = [["品目", "数量", "単価", "金額"]]
    invoice.invoice_items.each do |item|
      items << [
        item.description,
        item.quantity,
        number_to_currency(item.unit_price, unit: "¥", precision: 0, format: "%u%n"),
        number_to_currency(item.amount, unit: "¥", precision: 0, format: "%u%n")
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
    
    # 合計
    pdf.text "小計: #{number_to_currency(invoice.subtotal, unit: "¥", precision: 0, format: "%u%n")}", align: :right
    pdf.text "消費税(#{invoice.tax_rate}%): #{number_to_currency(invoice.tax_amount, unit: "¥", precision: 0, format: "%u%n")}", align: :right
    pdf.text "合計金額: #{number_to_currency(invoice.total, unit: "¥", precision: 0, format: "%u%n")}", align: :right, size: 14, style: :bold
    
    # 備考
    if invoice.notes.present?
      pdf.move_down 20
      pdf.text "【備考】", size: 12, style: :bold
      pdf.text invoice.notes, size: 12
    end
    
    # フッター
    pdf.repeat(:all) do
      pdf.bounding_box([0, 30], width: 540, height: 20) do
        pdf.text "#{invoice.issue_date} 発行", align: :right, size: 10
      end
    end
    
    pdf.render
  end
end
