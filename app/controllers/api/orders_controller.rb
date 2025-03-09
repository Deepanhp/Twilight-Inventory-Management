class Api::OrdersController < ApplicationController
  protect_from_forgery with: :null_session

  # def create
  #   item = Item.find_by(id: params[:item_id])
  #   member = Member.find_by(id: params[:member_id])
  #   quantity = params[:quantity].to_i

  #   if item.nil?
  #     render json: { success: false, errors: ["Item not found"] }, status: :not_found
  #     return
  #   end

  #   if quantity <= 0
  #     render json: { success: false, errors: ["Quantity must be greater than zero"] }, status: :unprocessable_entity
  #     return
  #   end

  #   if item.remaining_quantity < quantity
  #     render json: { success: false, errors: ["Not enough stock available"] }, status: :unprocessable_entity
  #     return
  #   end

  #   order = Order.new(item: item, quantity: quantity, status: true, member: member)

  #   if order.save
  #     item.update(remaining_quantity: item.remaining_quantity - quantity) # Reduce stock
  #     render json: { success: true, message: "Order placed successfully", redirect_url: orders_path }, status: :created
  #   else
  #     render json: { success: false, errors: order.errors.full_messages }, status: :unprocessable_entity
  #   end
  # end

  def create
    ActiveRecord::Base.transaction do
      @order = Order.new(member_id: params[:member_id])

      if @order.save
        params[:items].each do |order_item|
          item = Item.find(order_item[:item_id])
          requested_quantity = order_item[:requested_quantity].to_i
          requested_measurement = order_item[:requested_measurement].to_f

          # Validate order quantities
          if requested_quantity > item.remaining_quantity
            raise "Insufficient quantity available for #{item.name}"
          end

          # Calculate lengths
          original_length = item.measurements['meters'].to_f
          cut_length = original_length - requested_measurement  # This is what's left after cutting

          # Create order item for what customer gets
          @order.order_items.create!(
            item: item,
            quantity: requested_quantity,
            measurement_value: requested_measurement
          )

          # Update original item's quantity
          item.with_lock do
            item.update!(
              remaining_quantity: item.remaining_quantity - requested_quantity
            )
          end

          # Handle the cut piece (what's left after cutting)
          if cut_length > 0
            cut_piece = Item.find_by(
              category_id: item.category_id,
              sub_category_id: item.sub_category_id,
              company_id: item.company_id,
              measurements: { 'meters' => cut_length.to_f }
            )

            if cut_piece
              cut_piece.with_lock do
                cut_piece.update!(
                  quantity: cut_piece.quantity + requested_quantity,
                  remaining_quantity: cut_piece.remaining_quantity + requested_quantity
                )
              end
            else
              Item.create!(
                name: "#{item.sub_category.name} #{item.category.name}",
                category_id: item.category_id,
                sub_category_id: item.sub_category_id,
                company_id: item.company_id,
                quantity: requested_quantity,
                remaining_quantity: requested_quantity,
                measurements: { 'meters' => cut_length.to_f }
              )
            end
          end
        end

        render json: { success: true, order_id: @order.id }
      else
        render json: { success: false, error: @order.errors.full_messages.join(", ") }
      end
    end
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end



  # def chart_data
  #   timeframe = params[:timeframe] || "day"
      
  #   # case timeframe
  #   # when "day"
  #   #   orders = Order.group("DATE(created_at)").count
  #   # when "week"
  #   #   orders = Order.group("WEEK(created_at)").count
  #   # when "month"
  #   #   orders = Order.group("MONTH(created_at)").count
  #   # else
  #   #   orders = Order.group("DATE(created_at)").count
  #   # end

  #   if params[:timeframe] == "week"
  # 	  order_data = Order.group("strftime('%Y-%W', created_at)").count
  # 	elsif params[:timeframe] == "month"
  # 	  order_data = Order.group("strftime('%Y-%m', created_at)").count
  # 	else
  # 	  order_data = Order.group("DATE(created_at)").count
  # 	end

  #   render json: {
  #     labels: order_data.keys.map { |date| date.to_s },
  #     values: order_data.values
  #   }
  # end


  def orders_chart_data
    timeframe = params[:timeframe] || 'day'
    
    data = case timeframe
    when 'day'
      Order.group_by_day(:created_at, last: 7).count
    when 'week'
      Order.group_by_week(:created_at, last: 8).count
    when 'month'
      Order.group_by_month(:created_at, last: 6).count
    end

    labels = data.keys.map { |date| date.strftime('%Y-%m-%d') }
    values = data.values

    render json: {
      labels: labels,
      datasets: [{
        label: 'Orders',
        data: values,
        backgroundColor: 'rgba(54, 162, 235, 0.5)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 1
      }]
    }
  end



  def category_orders_chart_data
    category_data = OrderItem.joins(item: :category)
                           .group('categories.name')
                           .count

    # Generate colors for each category
    colors = category_data.keys.map.with_index do |_, index|
      "hsla(#{index * (360 / category_data.length)}, 70%, 60%, 0.5)"
    end

    render json: {
      labels: category_data.keys,
      datasets: [{
        label: 'Orders per Category',
        data: category_data.values,
        backgroundColor: colors,
        borderColor: colors.map { |color| color.gsub('0.5', '1') },
        borderWidth: 1
      }]
    }
  end
end
