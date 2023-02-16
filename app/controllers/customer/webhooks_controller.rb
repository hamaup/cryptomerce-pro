class Customer::WebhooksController < ApplicationController
  before_action :authenticate_customer!, except: [:create]
  skip_before_action :verify_authenticity_token, only: %i[create update_payment_status]

  def create
    slash_order = SlashOrder.find_by!(order_code: kickback_params[:order_code])
    slash_order.update!({
                          amount: kickback_params[:amount],
                          symbol: kickback_params[:symbol],
                          chain_id: kickback_params[:chain_id],
                          transaction_code: kickback_params[:transaction_code],
                          transaction_hash: kickback_params[:transaction_hash],
                          verify_token: kickback_params[:verify_token],
                          result: kickback_params[:result]
                        })
    status = kickback_params[:result] ? 'confirm_payment' : 'failure_payment'
    slash_order.order.update!({ status: })
  end

  def success
    # binding.pry
    slash_order = SlashOrder.find_by!(payment_token: confirm_params[:payment_token])
    if slash_order.order.status != 'confirm_payment'
      redirect_to failure_webhooks_path(payment_token: confirm_params[:payment_token]) and return 0
    end

    line_items = session[:line_items]
    line_items.each do |line_item|
      product = line_item['price_data']['product_data']
      purchased_product = Product.find(product['metadata']['product_id'])
      purchased_product.update!(stock: (purchased_product.stock - line_item['quantity']))
    end
    session[:line_items] = nil
    customer = Customer.find(current_customer.id)
    customer.cart_items.destroy_all
    OrderMailer.complete(email: current_customer.email).deliver_later
    redirect_to success_orders_path
  end

  def failure
    slash_order = SlashOrder.find_by!(payment_token: confirm_params[:payment_token])
    slash_order.order.update!({ status: 'failure_payment' }) if slash_order.order.status != 'failure_payment'
    redirect_to failure_orders_path
  end

  def update_payment_status
    # binding.pry
    slash_order = SlashOrder.find_by!(payment_token: update_payment_status_params[:payment_token])
    if slash_order.order.status == 'waiting_payment'
      slash_order.order.update!({ status: update_payment_status_params['status'] })
    end
    render json: { status: '200' }
  end

  def confirm
    slash_order = SlashOrder.find_by!(payment_token: confirm_params[:payment_token])
    if slash_order.order.status == 'confirm_payment'
      redirect_to success_webhooks_path(payment_token: confirm_params[:payment_token])
    else
      slash_order.order.update!({ status: 'failure_payment' })
      redirect_to failure_webhooks_path(payment_token: confirm_params[:payment_token])
    end
  end

  private

  def kickback_params
    @kickback_params ||= JSON.parse(request.body.read, { symbolize_names: true })
  end

  def confirm_params
    params.permit(:payment_token)
  end

  def update_payment_status_params
    params.require(:webhook).permit(:payment_token, :status)
  end
end
