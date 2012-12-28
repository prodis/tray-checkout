# encoding: UTF-8
module Tray
  module Checkout
    module Timeout
      DEFAULT_REQUEST_TIMEOUT = 5 #seconds
      attr_writer :request_timeout

      def request_timeout
        (@request_timeout ||= DEFAULT_REQUEST_TIMEOUT).to_i
      end
    end
  end
end
