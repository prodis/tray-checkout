# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::ResponseParser do
  describe "#parse" do
    context "with success response" do
      let(:xml) { body_for :get_success_boleto }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse }

      it "returns success" do
        response.success?.should be true
      end
    end

    context "with error response" do
      let(:xml) { body_for :get_failure_not_found }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse  }

      it "does not return success" do
        response.success?.should be false
      end

      context "returns error" do
        { code: "001001",
          message: "Token inv&aacute;lido ou n&atilde;o encontrado"
        }.each do |param, value|
          it param do
            response.errors.first[param].should == value
          end
        end
      end
    end

    context "with validation error response" do
      let(:xml) { body_for :create_failure_validation_errors }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse  }

      it "does not return success" do
        response.success?.should be false
      end

      context "returns error" do
        { code: "13",
          message: "Tipo de Contato não está incluído na lista"
        }.each do |param, value|
          it param do
            response.errors.first[param].should == value
          end
        end
      end
    end

    context "with general error response" do
      let(:xml) { body_for :create_failure_general_errors }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse }

      it "does not return success" do
        response.success?.should be false
      end

      context "returns error" do
        { code: "058001",
          message: "Revendedor inválido."
        }.each do |param, value|
          it param do
            response.errors.first[param].should == value
          end
        end
      end
    end
  end

  describe("transaction?") do
    context "response is from a transaction" do
      let(:xml) { body_for :get_success_boleto }

      it "returns true" do
        Tray::Checkout::ResponseParser.transaction?(xml).should be true
      end
    end

    context "response is not from a transaction" do
      let(:xml) { body_for :get_account_info }

      it "returns false" do
        Tray::Checkout::ResponseParser.transaction?(xml).should be false
      end
    end
  end
end
