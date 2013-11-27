# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::AccountResponseParser do
  describe "#parse" do
    context "with success response from get_info" do
      let(:xml) { body_for :get_account_info }
      let(:parser) { Tray::Checkout::AccountResponseParser.new(xml) }
      let(:response) { parser.parse }

      context "returns people" do
        {
          contact_primary: "08000059230",
          name: "Vendedor Loja Modelo",
          trade_name: "Loja Modelo",
          email: "lojamodelo@tray.com.br",
          url_logo: nil,
          css_url: "http://default.com/default.css"
        }.each do |param, value|
          it param do
            response.people[param].should == value
          end
        end
      end

      context "returns service_contact" do
        {
          service_phone: "(14)3412-1377",
          email_service: "lojamodelo@tray.com.br",
          service_phone_status: "true",
          email_service_status: "true"
        }.each do |param, value|
          it param do
            response.service_contact[param].should == value
          end
        end
      end

      context "returns seconds_redirect" do
        it 'returns the seconds_redirect parameter' do
          response.seconds_redirect.should be_nil
        end
      end
    end

    context "with error response" do
      let(:xml) { body_for :get_failure_not_found }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse  }

      [:people, :service_contact, :seconds_redirect].each do |info|
        it "returns nil #{info}" do
          response.send(info).should be_nil
        end
      end
    end

    context "with validation error response" do
      let(:xml) { body_for :create_failure_validation_errors }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse  }

      [:people, :service_contact, :seconds_redirect].each do |info|
        it "returns nil #{info}" do
          response.send(info).should be_nil
        end
      end
    end
  end
end
