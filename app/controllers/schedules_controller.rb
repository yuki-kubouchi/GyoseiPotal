class SchedulesController < ApplicationController
  def index
    @status = params[:status].to_s.strip
    @customer_id = params[:customer_id].presence
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

    scope = Application.includes(:customer).where.not(due_on: nil)
    scope = scope.where(status: Application.statuses[@status] || @status) if @status.present?
    scope = scope.where(customer_id: @customer_id) if @customer_id.present?
    scope = scope.where('due_on >= ?', @start_date) if @start_date
    scope = scope.where('due_on <= ?', @end_date) if @end_date

    @applications = scope.order(due_on: :asc, status: :asc)

    respond_to do |format|
      format.html do
        @by_date = @applications.group_by(&:due_on)
      end
      format.json do
        # FullCalendar supplies start/end (ISO8601). Filter by that window if provided.
        cal_start = begin
          Date.parse(params[:start]) if params[:start].present?
        rescue ArgumentError
          nil
        end
        cal_end = begin
          Date.parse(params[:end]) if params[:end].present?
        rescue ArgumentError
          nil
        end
        cal_scope = @applications
        cal_scope = cal_scope.where('due_on >= ?', cal_start) if cal_start
        cal_scope = cal_scope.where('due_on <= ?', cal_end) if cal_end

        render json: cal_scope.map { |a|
          {
            id: a.id,
            title: a.title,
            start: a.due_on&.strftime('%Y-%m-%d'),
            url: Rails.application.routes.url_helpers.application_path(a),
            extendedProps: {
              status: a.status,
              customer: a.customer&.code
            }
          }
        }
      end
    end
  end
end
