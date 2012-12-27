# encoding: UTF-8
module Tray
  module Checkout
    class TransactionParamsParser
      def initialize(params)
        @params = params.clone
      end

      def parse
        customer_map! @params[:customer]
        payment_map!  @params[:payment]
        products_map! @params
        @params
      end

      private

      def customer_map!(customer)
        return unless customer
        customer[:gender] = SEX[customer[:sex]] if customer[:sex]
        customer[:relationship] = MARITAL_STATUS[customer[:marital_status]] if customer[:marital_status]
        contacts_map!  customer[:contacts]
        addresses_map! customer[:addresses]
      end

      def payment_map!(payment)
        return unless payment
        payment[:payment_method_id] = PAYMENT_METHOD[payment[:method]] if payment[:method]
      end

      def contacts_map!(contacts)
        return unless contacts

        contacts.each do |contact|
          contact[:type_contact] = CONTACT_TYPE[contact[:type]] if contact[:type]
          contact[:number_contact] = contact.delete(:number)
        end
      end

      def addresses_map!(addresses)
        return unless addresses

        addresses.each do |address|
          address[:type_address] = ADDRESS_TYPE[address[:type]] if address[:type]
        end
      end

      def products_map!(params)
        return unless params[:transaction]
        params[:transaction_product] = params[:transaction].delete(:products)
      end
    end
  end
end
