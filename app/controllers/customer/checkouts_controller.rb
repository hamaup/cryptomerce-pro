class Customer::CheckoutsController < ApplicationController
  before_action :authenticate_customer!

  def create
    # binding.pry
    @cart_items = current_customer.cart_items
    line_items = session[:line_items] = current_customer.line_items_checkout

    # check item stock
    check_stock(line_items)

    @total = session[:total]
    amount = @total + POSTAGE

    # request payment token
    @payment_request_uimode = UIMODE
    order_code = generate_order_code
    payment = Api::Slash::PaymentRequest.new(order_code, amount, @payment_request_uimode)
    payment_request = payment.request
    @payment_request_json = payment_request.to_json.html_safe
    @payment_token = payment_request['token']

    @shipping_address = choose_shipping_address

    # create order
    ApplicationRecord.transaction do
      order = create_order(current_customer, amount)
      line_items.each do |line_item|
        create_order_details(order, line_item)
      end
      create_slash_order(order_code, @payment_token, order.id)
    end
  end

  private

  def generate_order_code
    "test_#{SecureRandom.hex(10)}"
  end

  def check_stock(line_items)
    line_items.each do |line_item|
      product = line_item[:price_data][:product_data]
      purchased_product = Product.find(product[:metadata][:product_id])
      next unless purchased_product.stock < 1

      redirect_to cart_items_path,
                  notice: "#{product[:name]}: Out of stock." and return 0

      payment_process_order_count = OrderDetail.joins(:order).where(product_id: product[:id],
                                                                    orders: { status: 'processing_payment' }).count
      next unless purchased_product.stock <= payment_process_order_count

      redirect_to cart_items_path,
                  notice: "#{product[:name]}: Out of stock." and return 0
    end
  end

  def create_order(customer, amount)
    Order.create!({
                    customer_id: customer.id,
                    name: customer.name,
                    postal_code: customer.postal_code,
                    prefecture: customer.prefecture,
                    address1: customer.address1,
                    address2: customer.address2,
                    postage: POSTAGE,
                    billing_amount: amount,
                    status: 'waiting_payment'
                  })
  end

  def create_order_details(order, line_item)
    product = line_item[:price_data][:product_data]
    purchased_product = Product.find(product[:metadata][:product_id])
    raise ActiveRecord::RecordNotFound if purchased_product.nil?

    order.order_details.create!({
                                  product_id: purchased_product.id,
                                  price: line_item[:price_data][:unit_amount],
                                  quantity: line_item[:quantity]
                                })
  end

  def create_slash_order(order_code, payment_token, order_id)
    SlashOrder.create!({
                         order_code:,
                         amount: '',
                         fiat_symbol: FIAT_SYMBOL,
                         symbol: '',
                         payment_token:,
                         chain_id: '',
                         transaction_code: '',
                         transaction_hash: '',
                         verify_token: '',
                         result: '',
                         order_id:
                       })
  end

  def choose_shipping_address
    shipping_address = Customer.select(:postal_code, :prefecture, :address1, :address2).find(current_customer.id)
    current_customer.postal_code = shipping_address.postal_code ||= '1110000'
    current_customer.prefecture = shipping_address.prefecture ||= 'test'
    current_customer.address1 = shipping_address.address1 ||= 'test'
    current_customer.address2 = shipping_address.address2 ||= 'test'
    shipping_address
  end
end
