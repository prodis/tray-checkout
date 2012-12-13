# encoding: UTF-8
module Tray
  module Checkout
    class Response
      attr_accessor :transaction, 
                    :payment, 
                    :customer, 
                    :success, 
                    :errors

      alias :success? :success

      def initialize
        @success = false
        @errors = []
      end
    end
  end
end
