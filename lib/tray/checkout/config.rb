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
          "https://api.traycheckout.com.br/"
        else
          "http://api.sandbox.traycheckout.com.br/"
        end
      end

      def cart_url
        if environment == :production
          "http://checkout.tray.com.br/"
        else
          "http://checkout.sandbox.tray.com.br/"
        end
      end

      def request_timeout
        (@request_timeout ||= DEFAULT_REQUEST_TIMEOUT).to_i
      end
    end
  end
end
