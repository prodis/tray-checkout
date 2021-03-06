# encoding: UTF-8
module Tray
  module Checkout
    class TempTransaction < Tray::Checkout::BaseService
      def api_url
        "#{Tray::Checkout.api_url}/v1/tmp_transactions/"
      end

      def initialize(token=nil)
        @token = token || Tray::Checkout.token_account
      end

      def cart_url
        "#{@response.transaction[:url_car]}#{@token_transaction}" if @token_transaction
      end

      def add_to_cart(params)
        @response = request("create", parser.response_params(params))

        @token_transaction = @response.transaction[:token] if @response.transaction

        @response
      end
    end
  end
end
