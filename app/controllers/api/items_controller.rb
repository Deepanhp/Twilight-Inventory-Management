class Api::ItemsController < ApplicationController
  protect_from_forgery with: :null_session

  def by_category
    category = Category.find_by(id: params[:category_id])

    if category
      items = category.items.map {|item| [item.id, item.get_formatted_name]} # Select only necessary fields
      render json: items
    else
      render json: { error: 'Category not found' }, status: :not_found
    end
  end

  def item_quantity
  	item = Item.find_by(id: params[:item_id])
  	if item
      item_data = {id: item.id, quantity: item.remaining_quantity} # Select only necessary fields
      render json: item_data
    else
      render json: { error: 'Category not found' }, status: :not_found
    end
  end

  def subcategories_by_category
    company_id = params[:company_id]
    category = Category.find_by(id: params[:category_id])
    
    if category && company_id.present?
      # Get subcategories that have items in the selected company
      subcategories = category.sub_categories
        .joins(:items)
        .where(items: { company_id: company_id })
        .select('DISTINCT sub_categories.id, sub_categories.name')
        .order(:name)  # Sort subcategories alphabetically
      
      render json: subcategories
    else
      render json: [], status: :not_found
    end
  rescue => e
    Rails.logger.error "Error in subcategories_by_category: #{e.message}"
    render json: { error: e.message }, status: :internal_server_error
  end

  def items_by_subcategory
    company_id = params[:company_id]
    subcategory = SubCategory.find(params[:subcategory_id])
    
    items = Item.where(
      sub_category_id: params[:subcategory_id],
      company_id: company_id
    )
    
    items_data = items.map do |item|
      measurement_key = item.category.measurement_types.include?('length') ? 'meters' : 'liters'
      {
        id: item.id,
        name: item.name,
        quantity: item.remaining_quantity,
        measurement: measurement_key,
        measurement_value: item.measurements[measurement_key].to_f,
        measurement_type: item.category.measurement_types.first
      }
    end

    # Sort items by measurement value in descending order
    items_data.sort_by! { |item| -item[:measurement_value] }

    render json: items_data
  end

  def item_quantity
    item = Item.find(params[:item_id])
    
    render json: {
      remaining_quantity: item.remaining_quantity,
      measurements: item.measurements # Assuming measurement is stored as { meters: 1000 } or { liters: 500 }
    }
  end
end
