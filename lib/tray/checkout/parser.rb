# encoding: UTF-8
module Tray
  module Checkout
    class Parser
      def response(xml)
        response_parser = ResponseParser.get_parser(xml)
        response_parser.parse
      end

      def response_params(params)
        response_params_parser = Tray::Checkout::ParamsParser.new(params)
        response_params_parser.parse
      end
    end
  end
end
