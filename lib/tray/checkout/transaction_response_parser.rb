# encoding: UTF-8

class Tray::Checkout::TransactionResponseParser < Tray::Checkout::ResponseParser
  def parse
    response = super

    if response.success?
      response.transaction = transaction
      response.payment = payment
      response.customer = customer
    end

    response
  end

  private

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

    transaction[:status] = Tray::Checkout::TRANSACTION_STATUS.invert[transaction.delete(:status_id)] if transaction.has_key?(:status_id)
    transaction[:id] = transaction.delete(:transaction_id) if transaction.has_key?(:transaction_id)
    transaction[:token] = transaction.delete(:token_transaction) if transaction.has_key?(:token_transaction)
    transaction[:products] = transaction.delete(:transaction_products) if transaction.has_key?(:transaction_products)
  end

  def payment_map!(transaction)
    return {} if transaction.blank? || transaction[:payment].blank?

    payment = transaction[:payment]

    payment[:method] = Tray::Checkout::PAYMENT_METHOD.invert[payment.delete(:payment_method_id)] if payment.has_key?(:payment_method_id)
    payment[:method_name] = payment.delete(:payment_method_name) if payment.has_key?(:payment_method_name)
    payment[:price] = payment.delete(:price_payment) if payment.has_key?(:price_payment)
  end

  def customer_map!(transaction)
    return {} if transaction.blank? || transaction[:customer].blank?

    customer = transaction[:customer]

    if customer[:contacts]
      customer[:contacts].each do |contact|
        contact[:type] = Tray::Checkout::CONTACT_TYPE.invert[contact.delete(:type_contact)] if contact.has_key?(:type_contact)
        contact[:id] = contact.delete(:contact_id) if contact.has_key?(:contact_id)
        contact[:number] = contact.delete(:value) if contact.has_key?(:value)
      end
    else
      customer[:contacts] = []
    end
  end
end
