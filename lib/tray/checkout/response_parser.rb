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
        hash = Hash.from_xml(@xml).symbolize_all_keys
        hash[:response] || hash[:tmp_transaction]
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
        data_response = response_hash[:data_response][:transaction] || response_hash[:data_response]
        transaction_map! data_response
        payment_map!     data_response
        customer_map!    data_response
        date_to_time!    data_response
        data_response
      end

      def transaction_map!(transaction)
        return {} unless transaction

        transaction[:status] = TRANSACTION_STATUS.invert[transaction.delete(:status_id)] if transaction.has_key?(:status_id)
        transaction[:id] = transaction.delete(:transaction_id) if transaction.has_key?(:transaction_id)
        transaction[:token] = transaction.delete(:token_transaction) if transaction.has_key?(:token_transaction)
        transaction[:products] = transaction.delete(:transaction_products) if transaction.has_key?(:transaction_products)
      end

      def payment_map!(transaction)
        return {} if transaction.blank? || transaction[:payment].blank?

        payment = transaction[:payment]

        payment[:method] = PAYMENT_METHOD.invert[payment.delete(:payment_method_id)] if payment.has_key?(:payment_method_id)
        payment[:method_name] = payment.delete(:payment_method_name) if payment.has_key?(:payment_method_name)
        payment[:price] = payment.delete(:price_payment) if payment.has_key?(:price_payment)
      end

      def customer_map!(transaction)
        return {} if transaction.blank? || transaction[:customer].blank?

        customer = transaction[:customer]

        if customer[:contacts]
          customer[:contacts].each do |contact|
            contact[:type] = CONTACT_TYPE.invert[contact.delete(:type_contact)] if contact.has_key?(:type_contact)
            contact[:id] = contact.delete(:contact_id) if contact.has_key?(:contact_id)
            contact[:number] = contact.delete(:value) if contact.has_key?(:value)
          end
        else
          customer[:contacts] = []
        end
      end

      def date_to_time!(hash)
        return nil unless hash

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
