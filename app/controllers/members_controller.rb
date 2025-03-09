class MembersController < ApplicationController
  before_action :set_member, only: [:edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @current_user = current_user
    company_id = @current_user&.role_type != 'super_admin' ? @current_user.company_id : params[:company_id]
    company = Company.find_by(id: company_id)
    if company.present?   
      @members = Member.where(company_id: params[:company_id])
    else
      @members = Member.all
    end
  end

  def new
    @current_user = current_user
    @member = Member.new
  end

  def edit
    @current_user = current_user
  end

  def create
    @current_user = current_user
    company_id = @current_user&.role_type != 'super_admin' ? @current_user.company_id : params[:company_id]
    company = Company.find_by(id: company_id)
    params[:member][:company_id] = company_id
    @member = Member.new(member_params)
    if @member.save
      redirect_to root_path(company_id: params[:company_id]), notice: 'Member was successfully created.'
    else
      render :new
    end
  end

  def update
    @current_user = current_user
    company_id = @current_user&.role_type != 'super_admin' ? @current_user.company_id : params[:company_id]
    company = Company.find_by(id: company_id)
    params[:member][:company_id] = company_id
    if @member.update(member_params)
      redirect_to :root, notice: 'Member was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @current_user = current_user
    if @member.orders.where(status: true).count == 0
      @member.destroy
      redirect_to :root, notice: 'Member was successfully destroyed.'
    else
      flash[:alert] = 'Members with active orders can not be deleted. Mark his/hers open orders as returned and try again.'
      redirect_to root_url
    end
  end

  private
    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:name, :email, :phone, :company_id)
    end
end
