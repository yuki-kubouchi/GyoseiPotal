module ApplicationHelper
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
      "#{base_classes} bg-gray-200 text-gray-800"
    else
      base_classes
    end
  end
end