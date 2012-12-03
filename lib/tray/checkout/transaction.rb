# encoding: UTF-8
module Tray
  module Checkout
    class Transaction
      URL = "http://api.sandbox.checkout.tray.com.br/api/transactions"

      def get(token)
        response = web_service.request!("#{URL}/get_by_token", { token: token })
        result = parser.response(response)
        result
      end

      private

      def web_service
        @web_service ||= Tray::Checkout::WebService.new
      end

      def parser
        @parser ||= Tray::Checkout::Parser.new
      end
    end
  end
end
