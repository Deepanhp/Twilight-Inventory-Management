class ApplicationController < ActionController::Base
  include ApplicationHelper
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :store_company_id
  before_action :authenticate_user!

  def after_sign_out_path_for(resource_or_scope)
    # root_path # or a different path
    new_user_session_path
  end

  private

  def store_company_id
    if params[:company_id].present?
      session[:company_id] = params[:company_id]
    end

    # Ensure all API calls include company_id
    params[:company_id] ||= session[:company_id]
  end
end
