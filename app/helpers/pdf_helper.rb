module PdfHelper
  def generate_estimate_pdf(invoice)
    require 'prawn'
    require 'prawn/table'
    
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      # 日本語フォント設定（システムフォントを使用）
      begin
        # Linux (Render)の場合
        if File.exist?('/usr/share/fonts/truetype/ipafont-gothic/ipag.ttf')
          pdf.font '/usr/share/fonts/truetype/ipafont-gothic/ipag.ttf'
        # macOSの場合  
        elsif File.exist?('/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc')
          pdf.font '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc'
        else
          # フォールバック: Prawnの組み込みフォント
          pdf.font 'Helvetica'
        end
      rescue => e
        Rails.logger.error "Font loading error: #{e.message}"
        pdf.font 'Helvetica'
      end
      
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
