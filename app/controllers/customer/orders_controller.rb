class Customer::OrdersController < ApplicationController
  def index
    @orders = current_customer.orders.latest
  end

  def show
    @order = current_customer.orders.find(params[:id])
  end

  def success; end

  def failure; end
end
