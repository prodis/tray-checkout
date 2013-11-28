# encoding: UTF-8

class Tray::Checkout::AccountResponseParser < Tray::Checkout::ResponseParser
  def parse
    response = super

    if response.success?
      response.people           = people
      response.service_contact  = service_contact
      response.seconds_redirect = seconds_redirect
    end

    response
  end

  private

  def people
    data_clone = data.clone
    data_clone.delete(:service_contact)
    data_clone.delete(:seconds_redirect)
    data_clone
  end

  def service_contact
    data[:service_contact]
  end

  def seconds_redirect
    data[:seconds_redirect] ? data[:seconds_redirect][:seconds_redirect] : nil
  end

  def create_data_response
    data_response = response_hash[:people] || response_hash[:data_response]
    people_map!           data_response
    service_contact_map!  data_response
    seconds_redirect_map! data_response
    date_to_time!         data_response
    data_response
  end

  def people_map!(people)
    return {} unless people

    people[:contact_primary] = people.delete(:contact_primary) if people.has_key?(:contact_primary)
    people[:name]            = people.delete(:name)            if people.has_key?(:name)
    people[:trade_name]      = people.delete(:trade_name)      if people.has_key?(:trade_name)
    people[:email]           = people.delete(:email)           if people.has_key?(:email)
    people[:url_logo]        = people.delete(:url_logo)        if people.has_key?(:url_logo)
    people[:css_url]         = people.delete(:css_url)         if people.has_key?(:css_url)
  end

  def service_contact_map!(people)
    return {} if people.blank? || people[:service_contact].blank?

    service_contact = people[:service_contact]

    service_contact[:service_phone]        = service_contact.delete(:service_phone) if service_contact.has_key?(:service_phone)
    service_contact[:email_service]        = service_contact.delete(:email_service) if service_contact.has_key?(:email_service)
    service_contact[:service_phone_status] = service_contact.delete(:service_phone_status)
    service_contact[:email_service_status] = service_contact.delete(:email_service_status)
  end

  def seconds_redirect_map!(people)
    return {} if people.blank? || people[:seconds_redirect].blank?

    seconds_redirect = people[:seconds_redirect]
    seconds_redirect = seconds_redirect.delete(:seconds_redirect) if seconds_redirect.has_key?(:seconds_redirect)
  end
end
