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

      private

      def convert_to_hash(xml)
        symbolize_all_keys!(Hash.from_xml(xml))[:transaction]
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

      def symbolize_all_keys!(hash)
        #TODO: Move to Hash class.
        case
        when hash.is_a?(Array)
          puts "### Array #{hash}"
          puts
          hash.each { |value| symbolize_all_keys!(value) }
        when hash.is_a?(Hash)
          puts "$$$ Hash: #{hash}"
          puts
          hash.symbolize_keys!

          hash.each_value do |value|
            value.symbolize_keys! if value.is_a?(Hash)
            symbolize_all_keys!(value)
          end
        end

        hash
      end
    end
  end
end
