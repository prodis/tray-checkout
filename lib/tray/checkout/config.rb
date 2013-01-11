# encoding: UTF-8
module Tray
  module Checkout
    module Config
      DEFAULT_REQUEST_TIMEOUT = 5 #seconds
      DEFAULT_ENVIRONMENT = :production

      attr_accessor :token_account
      attr_writer   :environment
      attr_writer   :request_timeout

      def environment
        @environment ||= DEFAULT_ENVIRONMENT
      end

      def api_url
        if environment == :production
          "https://api.checkout.tray.com.br/api/transactions"
        else
          "http://api.sandbox.checkout.tray.com.br/api/v1/transactions"
        end
      end

      def request_timeout
        (@request_timeout ||= DEFAULT_REQUEST_TIMEOUT).to_i
      end
    end
  end
end
