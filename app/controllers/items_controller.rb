class ItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_current_user

  def index
    @current_user = current_user
    @company_id = params[:company_id] || session[:company_id]
    @company = Company.find_by(id: @company_id)
    @categories = Category.all

    # Get items with their measurements and stock details
    base_query = Item.includes(:category, :sub_category)
    @items = if @company_id.present?
      base_query.where(company_id: @company_id)
    else
      # When "All Companies" is selected
      base_query.all
    end

    # Group items by category for better organization
    @items_by_category = @items.group_by(&:category)

    # Calculate category availability percentages safely
    @category_percentages = @categories.map do |category|
      total_quantity = category.items.sum(&:quantity).to_f
      if total_quantity > 0
        (category.items.sum(&:remaining_quantity).to_f / total_quantity * 100).round
      else
        0
      end
    end
  end

  def fetch_data
    items = Item.where(category_id: params[:category_id])
    render json: items.to_json(only: [:id, :name], methods: [:measurements])
  end

  def new
    @current_user = current_user
    @restricted_access = set_resticted_access(@current_user, params[:company_id].to_i)
    @item = Item.new
    @errors = []
  end

  def edit
    @current_user = current_user
  end

  def create
    @current_user = current_user
    
    # Get company_id from the header's company selector
    company_id = params[:company_id] || session[:company_id]
    
    # Validate company exists and is not "All Companies"
    unless company_id.present? && Company.exists?(company_id)
      flash[:error] = "Please select a specific company to add items"
      return render :new
    end
    
    # Permit and transform parameters
    permitted_params = params.permit(
      :description, 
      :category_id, 
      :subcategory_id,
      items: [:length, :volume, :quantity]
    )
    
    Rails.logger.debug "Permitted params: #{permitted_params.inspect}"

    category = Category.find_by(id: permitted_params[:category_id])
    @errors = []

    Rails.logger.debug "Processing category: #{category&.name}"
    Rails.logger.debug "Items params: #{permitted_params[:items]&.inspect}"

    if category && permitted_params[:items].present?
      allowed_types = category.measurement_types
      Rails.logger.debug "Allowed measurement types: #{allowed_types.inspect}"

      @items = permitted_params[:items].map do |item_params|
        measurement_data = {}

        if allowed_types.include?("length")
          measurement_data["meters"] = item_params[:length].to_f
        elsif allowed_types.include?("volume")
          measurement_data["liters"] = item_params[:volume].to_f
        end

        Rails.logger.debug "Creating item with measurements: #{measurement_data.inspect}"

        Item.new(
          description: permitted_params[:description],
          category_id: permitted_params[:category_id],
          company_id: company_id,
          measurements: measurement_data,
          quantity: item_params[:quantity].to_i,
          remaining_quantity: item_params[:quantity].to_i,
          sub_category_id: permitted_params[:subcategory_id]
        )
      end

      Rails.logger.debug "Created items: #{@items.map(&:attributes).inspect}"

      if @items.all?(&:valid?)
        ActiveRecord::Base.transaction do
          begin
            @items.each do |item|
              unless item.save
                @errors << item.errors.full_messages
                Rails.logger.error "Failed to save item: #{item.errors.full_messages}"
              end
            end
            
            if @errors.any?
              raise ActiveRecord::Rollback
            end
          rescue => e
            Rails.logger.error "Transaction failed: #{e.message}"
            @errors << e.message
            raise ActiveRecord::Rollback
          end
        end

        if @errors.any?
          flash[:error] = @errors.flatten.join(", ")
          render :new
        else
          flash[:success] = "Items added successfully"
          redirect_to items_path
        end
      else
        flash[:error] = "Error adding items: #{@items.map{|i| i.errors.full_messages}.flatten.join(', ')}"
        render :new
      end
    else
      flash[:error] = "Invalid category or missing measurements"
      render :new
    end
  rescue => e
    Rails.logger.error "Unexpected error in create: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash[:error] = "An unexpected error occurred"
    render :new
  end

  def update
    @current_user = current_user
    company_id = @current_user.role_type != 'super_admin' ? @current_user.company_id : params[:company_id]
    company = Company.find_by(id: company_id)
    params[:item][:company_id] = company_id
    if @item.update(item_params)
      redirect_to :root, notice: 'Item was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @current_user = current_user
    @item.destroy
    redirect_to items_url, notice: 'Item was successfully destroyed.'
  end

  def measurement_details
    item = Item.find(params[:id])

    render json: {
      measurement_type: item.measurement_type,
      default_quantity: item.measurement_type.in?(%w[weight volume]) ? item.default_quantity : nil,
      default_length: item.measurement_type == "length" ? item.default_length : nil,
      default_breadth: item.measurement_type == "length_x_breadth" ? item.default_breadth : nil
    }
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(
      :name, 
      :category, 
      :description, 
      :quantity, 
      :remaining_quantity, 
      :company_id, 
      :category_id,
      :subcategory_id,
      measurements: {}
    )
  end

  def set_current_user
    @current_user = current_user
  end

end
