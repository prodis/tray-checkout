# encoding: UTF-8
require 'active_support/core_ext'

module Tray
  module Checkout
    class Parser
      def response(xml)
        response_parser = ResponseParser.new(xml)
        response_parser.parse
      end

      def payment_params!(params)
        customer_params_types! params[:customer]
        payment_params_types! params[:payment]
        params
      end

      private

      def response_parser
        @response_parser ||= ResponseParser.new
      end

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
    end
  end
end
