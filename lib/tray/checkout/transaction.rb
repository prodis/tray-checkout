# encoding: UTF-8
module Tray
  module Checkout
    class Transaction
      URL = "http://api.sandbox.checkout.tray.com.br/api/transactions"

      def get(token)
        xml = web_service.request!("#{URL}/get_by_token", { token: token })
        parser.response(xml)
      end

      def create(params)
        xml = web_service.request!("#{URL}/pay_complete", parser.payment_params!(params))
        parser.response(xml)
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
