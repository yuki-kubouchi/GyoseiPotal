module PdfHelper
  def generate_estimate_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      # 日本語フォント設定（システムフォントを使用）
      font_path = nil
      
      # 候補フォントパスを順に検索
      font_candidates = [
        '/usr/share/fonts/truetype/ipafont-gothic/ipag.ttf',           # Render/Debian
        '/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf',           # 別のパス
        '/usr/share/fonts/truetype/fonts-japanese-gothic.ttf',         # 代替1
        Rails.root.join('app', 'assets', 'fonts', 'ipag.ttf').to_s,   # バンドルされたフォント
        '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc'               # macOS
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
      
      # フォントを設定
      pdf.font font_path
      
      # タイトル
      pdf.text "見積書", size: 24, style: :bold, align: :center
      pdf.move_down 20
      
      # 基本情報
      pdf.text "見積番号: #{invoice.invoice_number}", size: 12
      pdf.text "発行日: #{invoice.issue_date.strftime('%Y年%m月%d日')}", size: 12
      pdf.move_down 20
      
      # 顧客情報
      pdf.text "見積先", size: 14, style: :bold
      customer_name = invoice.customer.company_name.presence || invoice.customer.name
      pdf.text "#{customer_name} 御中", size: 12
      if invoice.application.title.present?
        pdf.text "案件: #{invoice.application.title}", size: 12
      end
      pdf.move_down 20
      
      # 明細テーブル
      pdf.text "明細", size: 14, style: :bold
      pdf.move_down 10
      
      table_data = [['品目', '数量', '単価', '金額']]
      invoice.invoice_items.each do |item|
        table_data << [
          item.description,
          item.quantity.to_s,
          number_with_delimiter(item.unit_price.to_i) + ' 円',
          number_with_delimiter(item.amount.to_i) + ' 円'
        ]
      end
      
      pdf.table(table_data, header: true, width: pdf.bounds.width,
                cell_style: { size: 10, padding: 8 }) do
        row(0).font_style = :bold
        row(0).background_color = 'EEEEEE'
      end
      
      pdf.move_down 20
      
      # 合計金額
      pdf.text "小計（税抜）: #{number_with_delimiter(invoice.subtotal.to_i)} 円", size: 12, align: :right
      pdf.text "消費税（10%）: #{number_with_delimiter(invoice.tax_amount.to_i)} 円", size: 12, align: :right
      pdf.text "合計（税込）: #{number_with_delimiter(invoice.total.to_i)} 円", size: 14, style: :bold, align: :right
    end.render
  end
end
