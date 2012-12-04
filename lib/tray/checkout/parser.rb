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
        date_to_time!(@response[:data_response])
        @response[:data_response][:success] = true
        @response[:data_response]
      end

      def date_to_time!(hash)
        hash.each do |key, value|
          date_to_time!(value) if value.is_a?(Hash)

          if key.to_s.starts_with?("date_") && value
            hash[key] = (value.to_time rescue value) || value
          end
        end
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
