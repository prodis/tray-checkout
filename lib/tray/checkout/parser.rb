# encoding: UTF-8
require 'active_support/core_ext'

module Tray
  module Checkout
    class Parser
      def response(xml)
        create_response_from(xml)
        success? ? data : errors
      end

      def payment_params!(params)
        customer_params_types! params[:customer]
        payment_params_types! params[:payment]

        params
      end

      private

      def customer_params_types!(customer)
        return unless customer
        customer[:gender] = SEX[customer[:sex]] if customer[:sex]
        customer[:relationship] = MARITAL_STATUS[customer[:marital_status]] if customer[:marital_status]
        contacts_params_types! customer[:contacts]
        addresses_params_types! customer[:addresses]
      end

      def payment_params_types!(payment)
        return unless payment
        payment[:payment_method_id] = PAYMENT_METHOD[payment[:payment_method]] if payment[:payment_method]
      end

      def contacts_params_types!(contacts)
        return unless contacts

        contacts.each do |contact|
          contact[:type_contact] = CONTACT_TYPE[contact[:contact_type]] if contact[:contact_type]
        end
      end

      def addresses_params_types!(addresses)
        return unless addresses

        addresses.each do |address|
          address[:type_address] = ADDRESS_TYPE[address[:address_type]] if address[:address_type]
        end
      end

      def create_response_from(xml)
        @response = Hash.from_xml(xml).symbolize_all_keys![:transaction]
      end

      def success?
        @response[:message_response][:message] == "success"
      end

      def data
        data_response = @response[:data_response][:transaction]
        transaction_response_types! data_response
        payment_response_types! data_response
        date_to_time! data_response
        data_response[:success] = true
        data_response
      end

      def transaction_response_types!(transaction)
        transaction[:payment_method] = PAYMENT_METHOD.invert[transaction[:payment_method_id]]
        transaction[:status] = TRANSACTION_STATUS.invert[transaction[:status_id]]
      end

      def payment_response_types!(transaction)
        payment = transaction[:payment]
        payment[:payment_method] = PAYMENT_METHOD.invert[payment[:payment_method_id]]
      end

      def errors
        error_response = @response[:error_response]

        if error_response[:validation_errors]
          error_response[:errors] = error_response.delete(:validation_errors)
        end

        error_response[:success] = false
        error_response
      end

      def date_to_time!(hash)
        hash.each do |key, value|
          date_to_time!(value) if value.is_a?(Hash)

          if key.to_s.starts_with?("date_") && value
            hash[key] = (value.to_time rescue value) || value
          end
        end
      end
    end
  end
end
