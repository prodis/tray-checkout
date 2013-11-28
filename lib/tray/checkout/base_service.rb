# encoding: UTF-8
module Tray
  module Checkout
    class BaseService
      protected

      def api_url
        raise NotImplementedError, "This method must be implemented in child classes."
      end

      def request(path, params)
        xml = web_service.request!("#{api_url}#{path}", params)
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
