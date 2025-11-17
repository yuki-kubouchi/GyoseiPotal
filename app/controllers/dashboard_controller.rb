class DashboardController < ApplicationController
  def index
    # Counts
    @incomplete_count = Application.where.not(status: Application.statuses[:approved]).count

    # Next due application
    @next_due_application = Application.where.not(due_on: nil).order(due_on: :asc).first

    # Approved this month
    @approved_this_month = Application.approved.where(due_on: Time.current.all_month).count

    # Top 5 in-progress applications (by nearest due date)
    @top_applications = Application.where(status: [Application.statuses[:draft], Application.statuses[:submitted], Application.statuses[:reviewing]])
                                   .where.not(due_on: nil)
                                   .includes(:customer)
                                   .order(due_on: :asc)
                                   .limit(5)

    # Upcoming schedule timeline (next items by due date)
    @upcoming_applications = Application.where.not(due_on: nil)
                                        .where('due_on >= ?', Date.current)
                                        .includes(:customer)
                                        .order(due_on: :asc)
                                        .limit(10)

    # Invoice total (this month): sum issued or paid invoices
    if defined?(Invoice)
      month_range = Time.current.all_month
      @invoice_total_yen = Invoice.where(issued_on: month_range)
                                  .where(status: [Invoice.statuses[:issued], Invoice.statuses[:paid]])
                                  .sum(:amount_yen)
    else
      @invoice_total_yen = 0
    end
  end
end
