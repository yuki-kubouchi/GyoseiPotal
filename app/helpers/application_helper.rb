module ApplicationHelper
  include Cocoon::ViewHelpers
  
  def format_date_with_weekday(date)
    return '' unless date
    
    weekdays = %w[日 月 火 水 木 金 土]
    weekday = weekdays[date.wday]
    
    "#{date.strftime('%-m/%-d')}(#{weekday})"
  end

  def status_badge_class(status)
    base_classes = "px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
    case status.to_sym
    when :draft
      "#{base_classes} bg-gray-100 text-gray-800"
    when :sent
      "#{base_classes} bg-blue-100 text-blue-800"
    when :paid
      "#{base_classes} bg-green-100 text-green-800"
    when :overdue
      "#{base_classes} bg-red-100 text-red-800"
    when :cancelled
      "#{base_classes} bg-yellow-100 text-yellow-800"
    else
      "#{base_classes} bg-gray-100 text-gray-800"
    end
  end
end
