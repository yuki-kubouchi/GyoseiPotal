module PdfHelper
  def generate_estimate_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      setup_japanese_font(pdf)
      
      # タイトル
      pdf.text "見積書", size: 24, align: :center
      pdf.move_down 30
      
      # 顧客情報（左上）
      customer_name = invoice.customer.company_name.presence || invoice.customer.name
      pdf.text "#{customer_name} 御中", size: 14
      if invoice.application.title.present?
        pdf.text "案件: #{invoice.application.title}", size: 11
      end
      pdf.move_down 20
      
      # 基本情報
      pdf.text "見積番号: #{invoice.invoice_number}", size: 11
      pdf.text "発行日: #{invoice.issue_date.strftime('%Y年%m月%d日')}", size: 11
      pdf.move_down 30
      
      # 明細テーブル（品目と金額のみ）
      pdf.text "明細", size: 14
      pdf.move_down 10
      
      table_data = [['品目', '金額']]
      invoice.invoice_items.each do |item|
        table_data << [
          item.description,
          number_with_delimiter(item.amount.to_i) + ' 円'
        ]
      end
      
      pdf.table(table_data, header: true, width: pdf.bounds.width,
                cell_style: { size: 11, padding: 8 },
                column_widths: { 0 => pdf.bounds.width * 0.7, 1 => pdf.bounds.width * 0.3 }) do
        row(0).background_color = 'EEEEEE'
        column(1).align = :right
      end
      
      pdf.move_down 20
      
      # 合計金額
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "合計（税込）: #{number_with_delimiter(invoice.total.to_i)} 円", size: 16, align: :right
      
      pdf.move_down 40
      
      # 発行者情報
      office = OfficeSetting.instance
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.text "発行者情報", size: 12
      pdf.move_down 5
      pdf.text office.name, size: 11
      pdf.text "〒#{office.postal_code} #{office.address}", size: 10 if office.postal_code.present? || office.address.present?
      pdf.text "TEL: #{office.phone}", size: 10 if office.phone.present?
      pdf.text "Email: #{office.email}", size: 10 if office.email.present?
      
      # 振込先情報
      if office.bank_name.present? || office.account_number.present?
        pdf.move_down 20
        pdf.stroke_horizontal_rule
        pdf.move_down 15
        pdf.text "振込先（参考）", size: 12
        pdf.move_down 5
        pdf.text "銀行名: #{office.bank_name}", size: 10 if office.bank_name.present?
        pdf.text "支店名: #{office.branch_name}", size: 10 if office.branch_name.present?
        pdf.text "口座種別: #{office.account_type}", size: 10 if office.account_type.present?
        pdf.text "口座番号: #{office.account_number}", size: 10 if office.account_number.present?
        pdf.text "口座名義: #{office.account_holder}", size: 10 if office.account_holder.present?
      end
    end.render
  end

  def generate_invoice_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      setup_japanese_font(pdf)
      
      # タイトル
      pdf.text "請求書", size: 24, align: :center
      pdf.move_down 30
      
      # 顧客情報（左上）
      customer_name = invoice.customer.company_name.presence || invoice.customer.name
      pdf.text "#{customer_name} 様", size: 14
      if invoice.application.title.present?
        pdf.text "案件: #{invoice.application.title}", size: 11
      end
      pdf.move_down 20
      
      # 基本情報
      pdf.text "請求番号: #{invoice.invoice_number}", size: 11
      pdf.text "発行日: #{invoice.issue_date.strftime('%Y年%m月%d日')}", size: 11
      pdf.text "支払期限: #{invoice.due_date.strftime('%Y年%m月%d日')}", size: 11 if invoice.due_date
      pdf.move_down 30
      
      # 明細テーブル（品目と金額のみ）
      pdf.text "明細", size: 14
      pdf.move_down 10
      
      table_data = [['品目', '金額']]
      invoice.invoice_items.each do |item|
        table_data << [
          item.description,
          number_with_delimiter(item.amount.to_i) + ' 円'
        ]
      end
      
      # 請求書のテーブル
      pdf.table(table_data, header: true, width: pdf.bounds.width,
                cell_style: { size: 11, padding: 8 },
                column_widths: { 0 => pdf.bounds.width * 0.7, 1 => pdf.bounds.width * 0.3 }) do
        row(0).background_color = 'EEEEEE'
        column(1).align = :right
      end
      
      pdf.move_down 20
      
      # 合計金額
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "請求金額: #{number_with_delimiter(invoice.total.to_i)} 円", size: 16, align: :right
      
      pdf.move_down 40
      
      # 発行者情報
      office = OfficeSetting.instance
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.text "発行者情報", size: 12
      pdf.move_down 5
      pdf.text office.name, size: 11
      pdf.text "〒#{office.postal_code} #{office.address}", size: 10 if office.postal_code.present? || office.address.present?
      pdf.text "TEL: #{office.phone}", size: 10 if office.phone.present?
      pdf.text "Email: #{office.email}", size: 10 if office.email.present?
      
      # 振込先情報
      if office.bank_name.present? || office.account_number.present?
        pdf.move_down 20
        pdf.stroke_horizontal_rule
        pdf.move_down 15
        pdf.text "振込先", size: 12
        pdf.move_down 5
        pdf.text "銀行名: #{office.bank_name}", size: 10 if office.bank_name.present?
        pdf.text "支店名: #{office.branch_name}", size: 10 if office.branch_name.present?
        pdf.text "口座種別: #{office.account_type}", size: 10 if office.account_type.present?
        pdf.text "口座番号: #{office.account_number}", size: 10 if office.account_number.present?
        pdf.text "口座名義: #{office.account_holder}", size: 10 if office.account_holder.present?
        pdf.move_down 10
        pdf.text "お支払期日: #{invoice.due_date.strftime('%Y年%m月%d日')}", size: 10, style: :bold
      end
    end.render
  end

  def generate_receipt_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      setup_japanese_font(pdf)
      
      # タイトル
      pdf.text "領収書", size: 24, align: :center
      pdf.move_down 30
      
      # 顧客情報
      customer_name = invoice.customer.company_name.presence || invoice.customer.name
      pdf.text "#{customer_name} 様", size: 14
      pdf.move_down 20
      
      # 基本情報
      pdf.text "領収書番号: #{invoice.invoice_number}", size: 11
      pdf.text "発行日: #{invoice.issue_date.strftime('%Y年%m月%d日')}", size: 11
      pdf.move_down 25
      
      # 領収金額
      pdf.text "下記の通り領収いたします。", size: 12
      pdf.move_down 15
      
      # 金額ボックス（背景色付き）
      amount_box_y = pdf.cursor
      pdf.fill_color 'F5F5F5'
      pdf.fill_rectangle [0, amount_box_y], pdf.bounds.width, 80
      pdf.fill_color '000000'
      
      pdf.move_down 15
      pdf.text "¥#{number_with_delimiter(invoice.total.to_i)}ー", size: 22, align: :center
      pdf.text "(税込)", size: 11, align: :center
      pdf.move_down 15
      
      pdf.move_down 10
      
      # 但し書き
      if invoice.application.title.present?
        pdf.text "但し: #{invoice.application.title}として", size: 11
      end
      pdf.move_down 25
      
      # 明細テーブル（品目と金額のみ）
      pdf.text "内訳", size: 14
      pdf.move_down 10
      
      table_data = [['品目', '金額']]
      invoice.invoice_items.each do |item|
        table_data << [
          item.description,
          number_with_delimiter(item.amount.to_i) + ' 円'
        ]
      end
      
      pdf.table(table_data, header: true, width: pdf.bounds.width,
                cell_style: { size: 11, padding: 8 },
                column_widths: { 0 => pdf.bounds.width * 0.7, 1 => pdf.bounds.width * 0.3 }) do
        row(0).background_color = 'EEEEEE'
        column(1).align = :right
      end
      
      pdf.move_down 20
      
      # 合計
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "合計: #{number_with_delimiter(invoice.total.to_i)} 円", size: 16, align: :right
      
      pdf.move_down 40
      
      # 発行者情報
      office = OfficeSetting.instance
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.text "発行者情報", size: 12
      pdf.move_down 5
      pdf.text office.name, size: 11
      pdf.text "〒#{office.postal_code} #{office.address}", size: 10 if office.postal_code.present? || office.address.present?
      pdf.text "TEL: #{office.phone}", size: 10 if office.phone.present?
      pdf.text "Email: #{office.email}", size: 10 if office.email.present?
    end.render
  end

  private

  def setup_japanese_font(pdf)
    font_path = nil
    
    font_candidates = [
      '/usr/share/fonts/truetype/ipafont-gothic/ipag.ttf',
      '/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf',
      '/usr/share/fonts/truetype/fonts-japanese-gothic.ttf',
      Rails.root.join('app', 'assets', 'fonts', 'ipag.ttf').to_s,
      '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc'
    ]
    
    font_candidates.each do |path|
      if File.exist?(path)
        font_path = path
        Rails.logger.info "Using font: #{font_path}"
        break
      end
    end
    
    if font_path.nil?
      Rails.logger.error "No Japanese font found! Checked paths: #{font_candidates.join(', ')}"
      raise "Japanese font not available"
    end
    
    pdf.font_families.update(
      'IPAGothic' => {
        normal: font_path
      }
    )
    
    pdf.font 'IPAGothic'
  end
end
