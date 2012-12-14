# encoding: UTF-8
module Tray
  module Checkout
    class TransactionParamsParser
      def initialize(params)
        @params = params.clone
      end

      def parse
        customer_types! @params[:customer]
        payment_types! @params[:payment]
        products! @params
        @params
      end

      private

      def customer_types!(customer)
        return unless customer
        customer[:gender] = SEX[customer[:sex]] if customer[:sex]
        customer[:relationship] = MARITAL_STATUS[customer[:marital_status]] if customer[:marital_status]
        contacts_types! customer[:contacts]
        addresses_types! customer[:addresses]
      end

      def payment_types!(payment)
        return unless payment
        payment[:payment_method_id] = PAYMENT_METHOD[payment[:payment_method]] if payment[:payment_method]
      end

      def contacts_types!(contacts)
        return unless contacts

        contacts.each do |contact|
          contact[:type_contact] = CONTACT_TYPE[contact[:contact_type]] if contact[:contact_type]
        end
      end

      def addresses_types!(addresses)
        return unless addresses

        addresses.each do |address|
          address[:type_address] = ADDRESS_TYPE[address[:address_type]] if address[:address_type]
        end
      end

      def products!(params)
        return unless params[:transaction]
        params[:transaction_product] = params[:transaction].delete(:products)
      end
    end
  end
end
