module Api
  module Slash
    class PaymentRequest
      attr_accessor :query

      def initialize(order_code, amount, payment_request_uimode)
        # Authentication Token
        api_token = Rails.application.credentials.dig(:slash, :authentication_token)
        # Hash Token
        hash_token = Rails.application.credentials.dig(:slash, :hash_token)
        # Set amount and Generate verify token
        raw = "#{order_code}::#{amount}::#{hash_token}"
        verify_token = Digest::SHA256.hexdigest(raw)

        @data = {
          'identification_token': api_token,
          'order_code': order_code,
          'verify_token': verify_token,
          'amount': amount,
          'amount_type': FIAT_SYMBOL
        }
        @data['uimode'] = 'switchable' if payment_request_uimode == 'switchable'
        # data to be sent to api
      end

      def request
        # api-endpoint
        api_endpoint = URI.parse('https://testnet.slash.fi/api/v1/payment/receive')
        # sending post request and saving response as response object
        r = Net::HTTP.post_form(api_endpoint, @data)
        # extracting response text
        JSON.parse(r.body)
      end
    end
  end
end
