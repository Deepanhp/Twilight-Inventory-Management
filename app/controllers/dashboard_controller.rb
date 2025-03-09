class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user

  def index
    @current_user = current_user
    company_id = params[:company_id] || session[:company_id]

    # Get categories that have items for the selected company
    @categories = if company_id.present?
      Category
        .joins(:items)
        .where(items: { company_id: company_id })
        .distinct
        .includes(:items)
    else
      # When "All Companies" is selected
      Category.includes(:items).distinct
    end

    # Calculate category availability percentages for the selected company
    # @category_percentages = @categories.map do |category|
    #   items = company_id.present? ? category.items.where(company_id: company_id) : category.items
    #   total_quantity = items.sum(&:quantity).to_f
    #   if total_quantity > 0
    #     remaining = items.sum(&:remaining_quantity).to_f
    #     (remaining / total_quantity * 100).round
    #   else
    #     0
    #   end
    # end

    # Get recent orders for the selected company
    @recent_orders = Order
      .includes(:member, order_items: [:item])
      .where(order_items: { items: { company_id: company_id } })
      .order(created_at: :desc)
      .limit(5)
      .distinct

    # # Get chart data for the selected company (last 7 days)
    # @orders_chart_data = get_orders_by_day(company_id)

    # @category_orders_data = Order
    #   .joins(:item)
    #   .where(company_id.present? ? { items: { company_id: company_id } } : {})
    #   .group('items.category_id')
    #   .count

    @buyers = Member.all

    @low_stock_items = @categories.each_with_object({}) do |category, hash|
      items = company_id.present? ? category.items.where(company_id: company_id) : category.items
      low_stock = items.select { |item| item.stock_status == :low_stock }
      hash[category.name] = low_stock if low_stock.any?
    end

    respond_to do |format|
      format.html # Render ERB view
      format.json { render json: dashboard_data }
    end
  end

  private

  def set_current_user
    @current_user = current_user
  end

  def get_orders_by_day(company_id)
    # Get orders for the last 7 days
    start_date = 7.days.ago.beginning_of_day
    end_date = Time.current.end_of_day

    orders = Order.joins(:item)
    
    # Add company filter only if company_id is present
    orders = orders.where(items: { company_id: company_id }) if company_id.present?
    
    # Add date range filter and group by day
    orders
      .where(created_at: start_date..end_date)
      .group("DATE(created_at)")
      .count
  end

  def dashboard_data
    {
      categories: @categories.map do |category|
        {
          name: category.name,
          items: category.items.map { |item| { name: item.name, remaining_quantity: item.remaining_quantity } }
        }
      end,
      low_stock_items: @low_stock_items,
      buyers: @buyers.map { |buyer| { name: buyer.name, email: buyer.email, phone: buyer.phone } }
    }
  end
end
