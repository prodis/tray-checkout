# encoding: UTF-8

def mock_request_for(response)
  url = Regexp.new(Tray::Checkout.api_url)
  WebMock::API.stub_request(:post, url).to_return(:status => 200, :body => body_for(response))
end

def body_for(response)
  case response
  when :get_success_boleto,
       :get_success_boleto_without_contacts,
       :get_success_mastercard,
       :get_failure_not_found,
       :create_success_boleto,
       :create_success_mastercard,
       :create_failure_validation_errors,
       :create_failure_general_errors,
       :create_temp_transaction_with_token,
       :get_account_info
    read_file_for(response)
  else
    response
  end
end

def read_file_for(filename)
  File.open("#{File.dirname(__FILE__)}/responses/#{filename}.xml").read
end
