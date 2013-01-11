# encoding: UTF-8
module Tray
  module Checkout
    class Transaction
      def get(token)
        request("get_by_token", { token: token })
      end

      def create(params)
        request("pay_complete", parser.transaction_params(params))
      end

      private

      def request(path, params)
        xml = web_service.request!("#{Tray::Checkout.api_url}/#{path}", params)
        parser.response(xml)
      end

      def web_service
        @web_service ||= Tray::Checkout::WebService.new
      end

      def parser
        @parser ||= Tray::Checkout::Parser.new
      end
    end
  end
end
