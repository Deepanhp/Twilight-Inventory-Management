class SubCategoriesController < ApplicationController
  def index
    category = Category.find(params[:category_id])
    subcategories = category.sub_categories.select(:id, :name)
    render json: subcategories
  rescue ActiveRecord::RecordNotFound
    render json: [], status: :not_found
  end
end 