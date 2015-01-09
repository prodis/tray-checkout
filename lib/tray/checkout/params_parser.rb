# encoding: UTF-8
module Tray
  module Checkout
    class ParamsParser
      def initialize(params)
        @params = params.clone
      end

      def parse
        token_account! @params
        customer_map! @params[:customer]
        payment_map!  @params[:payment]
        products_map! @params
        @params
      end

      private

      def token_account!(params)
        params[:token_account] = Tray::Checkout.token_account if params[:token_account].nil?
      end

      def customer_map!(customer)
        return unless customer
        customer[:birth_date] = customer[:birth_date].strftime("%d/%m/%Y") if customer[:birth_date] && customer[:birth_date].is_a?(Date)
        customer[:gender] = SEX[customer[:sex]] if customer[:sex]
        customer[:relationship] = MARITAL_STATUS[customer[:marital_status]] if customer[:marital_status]
        contacts_map!  customer[:contacts]
        addresses_map! customer[:addresses]
      end

      def payment_map!(payment)
        return unless payment
        payment[:payment_method_id] = PAYMENT_METHOD[payment[:method]] if payment[:method]
        payment[:card].each { |key, value| payment["card_#{key}".to_sym] = value } if payment[:card]
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

        params[:transaction_product].each do |product|
          product.delete(:url_img) if product[:url_img].to_s.empty?
        end
      end
    end
  end
end
