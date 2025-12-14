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
                cell_style: { size: 11, padding: 8 }) do
        row(0).background_color = 'EEEEEE'
        column(0).width = 350
        column(1).width = 150
        column(1).align = :right
      end
      
      pdf.move_down 20
      
      # 合計金額
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "合計（税込）: #{number_with_delimiter(invoice.total.to_i)} 円", size: 16, align: :right
      
      pdf.move_down 40
      
      # 発行者情報
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.text "発行者情報", size: 12
      pdf.move_down 5
      pdf.text "行政書士事務所", size: 11
      pdf.text "〒123-4567 東京都〇〇区〇〇1-2-3", size: 10
      pdf.text "TEL: 03-1234-5678", size: 10
      pdf.text "Email: info@example.com", size: 10
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
      
      pdf.table(table_data, header: true, width: pdf.bounds.width,
                cell_style: { size: 11, padding: 8 }) do
        row(0).background_color = 'EEEEEE'
        column(0).width = 350
        column(1).width = 150
        column(1).align = :right
      end
      
      pdf.move_down 20
      
      # 合計金額
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "請求金額: #{number_with_delimiter(invoice.total.to_i)} 円", size: 16, align: :right
      
      pdf.move_down 40
      
      # 発行者情報
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.text "発行者情報", size: 12
      pdf.move_down 5
      pdf.text "行政書士事務所", size: 11
      pdf.text "〒123-4567 東京都〇〇区〇〇1-2-3", size: 10
      pdf.text "TEL: 03-1234-5678", size: 10
      pdf.text "Email: info@example.com", size: 10
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
      pdf.text "¥#{number_with_delimiter(invoice.total.to_i)}", size: 22, align: :center
      pdf.text "(税込)", size: 11, align: :center
      pdf.move_down 25
      
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
                cell_style: { size: 11, padding: 8 }) do
        row(0).background_color = 'EEEEEE'
        column(0).width = 350
        column(1).width = 150
        column(1).align = :right
      end
      
      pdf.move_down 20
      
      # 合計
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "合計: #{number_with_delimiter(invoice.total.to_i)} 円", size: 16, align: :right
      
      pdf.move_down 40
      
      # 発行者情報
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.text "発行者情報", size: 12
      pdf.move_down 5
      pdf.text "行政書士事務所", size: 11
      pdf.text "〒123-4567 東京都〇〇区〇〇1-2-3", size: 10
      pdf.text "TEL: 03-1234-5678", size: 10
      pdf.text "Email: info@example.com", size: 10
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
