class OrdersController < ApplicationController
  # before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_order, only: [:destroy]
  before_action :authenticate_user!

  def index
    @orders = Order.includes(:member, order_items: :item).order(created_at: :desc)
  end

  def show
    @order = Order.includes(:member, order_items: :item).find(params[:id])
  end

  def old
    @current_user = current_user
    @inactive = Order.inactive?
  end

  def renew
    @current_user = current_user
    @order = Order.find_by_id(params[:id])
    Order.renew(params[:id])
    redirect_to :root
    flash[:notice] = "Renewed for 7 days from now. Enjoy!"

    begin
      OrderMailer.delay.renew_order(@order, @current_user).deliver
    rescue Exception => e
    end
  end

  def disable
    @current_user = current_user
    borrowed_qty = Order.find_by_id(params[:id]).quantity.to_i
    @borrowed_item = Order.find_by_id(params[:id]).item
    @borrowed_item.increment!(:remaining_quantity, borrowed_qty)
    @current_user = current_user
    @order = Order.find_by_id(params[:id])
    Order.disable(params[:id])
    redirect_to :root
    flash[:notice] = "Item marked as returned. Thank you!"

    begin
      OrderMailer.delay.return_order(@order, @current_user).deliver
    rescue Exception => e
    end
  end

  def new
    @current_user = current_user
    @restricted_access = set_resticted_access(@current_user, params[:company_id].to_i)
    company_id = @current_user.role_type != 'super_admin' ? @current_user.company_id : params[:company_id]
    @order = Order.new
    company = Company.find_by(id: company_id)
    if company.present?
      @member = Member.where(company_id: company_id)
      @products = Item.where(company_id: company_id)
    else
      @member = Member.all
      @products = Item.all
    end
  end

  def create
    @current_user = current_user
    company_id = @current_user.role_type != 'super_admin' ? @current_user.company_id : params[:company_id]
    company = Company.find_by(id: company_id)
    puts "paramssssssssssssssssssss - #{params}"
    params[:order][:company_id] = company_id
    if Item.find_by_id(params[:order][:item_id]).remaining_quantity >= params[:order][:quantity].to_i
      params[:order][:status] = true
      @order = Order.new(order_params)
      if @order.save
        @current_user = current_user
        @borrowed_item = Item.find_by_id(params[:order][:item_id])
        @borrowed_item.decrement!(:remaining_quantity, params[:order][:quantity].to_i)
        redirect_to :root, notice: 'Order was successfully created.'
        begin
          OrderMailer.delay.create_order(@order, @current_user).deliver
        rescue Exception => e
        end
      else
        render :new
      end
    else
      flash[:alert] = 'The quantity you entered is not currently available'
      render :new
    end
  end

  def destroy
    @current_user = current_user
    borrowed_qty = @order.quantity.to_i
    @borrowed_item = @order.item
    @borrowed_item.increment!(:remaining_quantity, borrowed_qty)
    @current_user = current_user
    @order.destroy

    redirect_to orders_url, notice: 'Order was successfully destroyed.'
    begin
      OrderMailer.delay.cancel_order(@order, @current_user).deliver
    rescue Exception => e
    end
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:quantity, :expire_at, :status, :item_id, :member_id, :company_id, :length, :breadth)
    end
end
