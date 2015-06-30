# encoding: UTF-8
require 'active_support/core_ext'

class Tray::Checkout::ResponseParser
  def self.transaction?(xml)
    xml.include?('<transaction>') || xml.include?('<tmp_transaction>')
  end

  def self.get_parser(xml)
    #TODO: Remove this POG, please!
    Tray::Checkout::ResponseParser.transaction?(xml) ?
      Tray::Checkout::TransactionResponseParser.new(xml) :
      Tray::Checkout::AccountResponseParser.new(xml)
  end

  def initialize(xml)
    @xml = xml
  end

  def parse
    response = Tray::Checkout::Response.new
    response.success = success?

    unless response.success?
      response.errors = errors
    end

    response
  end

  protected

  def response_hash
    @response_hash ||= create_response_hash
  end

  def create_response_hash
    hash = Hash.from_xml(@xml).symbolize_all_keys
    hash[:response] || hash[:tmp_transaction] || hash[:people]
  end

  def success?
    response_hash[:message_response][:message] == "success"
  end

  def data
    @data ||= create_data_response
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

    if error_response[:general_errors]
      error_response[:errors] = error_response.delete(:general_errors)
    end

    error_response[:errors]
  end
end
