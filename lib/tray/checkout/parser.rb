# encoding: UTF-8
module Tray
  module Checkout
    class Parser
      def response(xml)
        response_parser = ResponseParser.new(xml)
        response_parser.parse
      end

      def transaction_params(params)
        transaction_params_parser = Tray::Checkout::TransactionParamsParser.new(params)
        transaction_params_parser.parse
      end
    end
  end
end
