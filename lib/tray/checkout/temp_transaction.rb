# encoding: UTF-8
module Tray
  module Checkout
    class TempTransaction < Tray::Checkout::BaseTransaction
      def api_url
        "#{Tray::Checkout.api_url}/v1/tmp_transactions/"
      end

      def initialize(token=nil)
        @token = token || Tray::Checkout.token_account
      end

      def cart_url
        "#{Tray::Checkout.cart_url}payment/car/v1/#{@token}" if @token
      end

      def add_to_cart(params)
        request("create", parser.transaction_params(params))
      end
    end
  end
end