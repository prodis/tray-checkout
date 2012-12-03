# encoding: UTF-8
require 'active_support/core_ext'

module Tray
  module Checkout
    class Parser
      def response(xml)
        puts xml
        hash = convert_to_hash(xml)
        success?(hash) ? data(hash) : errors(hash)
      end

      def payment_params(hash)
        #TODO
        hash
      end

      private

      def convert_to_hash(xml)
        Hash.from_xml(xml).symbolize_all_keys![:transaction]
      end

      def success?(hash)
        hash[:message_response][:message] == "success"
      end

      def data(hash)
        hash[:data_response]
      end

      def errors(hash)
        hash[:error_response]
      end
    end
  end
end
