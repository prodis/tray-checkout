# encoding: UTF-8
require 'active_support/core_ext'

module Tray
  module Checkout
    class ResponseParser
      def initialize(xml)
        @xml = xml
      end

      def parse
        response = Response.new
        response.success = success?

        if response.success?
          response.transaction = transaction
          response.payment = payment
          response.customer = customer
        else
          response.errors = errors
        end

        response
      end

      private

      def response_hash
        @response_hash ||= create_response_hash
      end

      def create_response_hash
        Hash.from_xml(@xml).symbolize_all_keys[:transaction]
      end

      def success?
        response_hash[:message_response][:message] == "success"
      end

      def transaction
        data_clone = data.clone
        data_clone.delete(:payment)
        data_clone.delete(:customer)
        data_clone
      end

      def payment
        data[:payment]
      end

      def customer
        data[:customer]
      end

      def data
        @data ||= create_data_response
      end

      def create_data_response
        data_response = response_hash[:data_response][:transaction]
        transaction_types! data_response
        payment_types! data_response
        date_to_time! data_response
        data_response
      end

      def transaction_types!(transaction)
        transaction[:status] = TRANSACTION_STATUS.invert[transaction[:status_id]]
      end

      def payment_types!(transaction)
        payment = transaction[:payment]
        payment[:payment_method] = PAYMENT_METHOD.invert[payment[:payment_method_id]]
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
        error_response = response_hash[:error_response]

        if error_response[:validation_errors]
          error_response[:errors] = error_response.delete(:validation_errors)
        end

        error_response[:errors]
      end
    end
  end
end
