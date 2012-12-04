# encoding: UTF-8
require 'active_support/core_ext'

module Tray
  module Checkout
    class Parser
      def response(xml)
        #puts xml
        create_response_from(xml)
        success? ? data : errors
      end

      def payment_params(hash)
        #TODO
        hash
      end

      private

      def create_response_from(xml)
        @response = Hash.from_xml(xml).symbolize_all_keys![:transaction]
      end

      def success?
        @response[:message_response][:message] == "success"
      end

      def data
        @response[:data_response][:success] = true
        @response[:data_response]
      end

      def errors
        error_response = @response[:error_response]

        if error_response[:validation_errors]
          error_response[:errors] = error_response.delete(:validation_errors)
        end

        error_response[:success] = false
        error_response
      end
    end
  end
end
