# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Parser do
  let(:parser) { Tray::Checkout::Parser.new }

  describe "#response" do
    context "with success response" do
      let(:xml) { body_for :get_success_boleto }
      let(:result) { parser.response(xml) }

      it "returns success" do
        result[:success].should be_true
      end

      context "returns transaction" do
        { transaction_token: "522045453u5uu32e0u8014f060uuu5uu",
          transaction_id: 501,
          payment_method_id: 6, #TODO: Symbol
          payment_method_name: "Boleto Bancario",
          status_id: 4, #TODO: Symbol
          status_name: "Aguardando Pagamento",
          order_number: "R1240",
          price_original: 213.21,
          price_payment: 213.21,
          price_seller: 199.19,
          price_additional: 0.00,
          price_discount: 0.00,
          shipping_type: "Sedex",
          shipping_price: 1.23,
          split: 1,
          date_transaction: "2012-12-03T18:08:37", #TODO: DateTime
          url_notification: "http://prodis.blog.br/tray_notification",
          seller_token: "949u5uu9ef36f7u"
        }.each do |param, value|
          it param do
            result[:transaction][param].should == value
          end
        end
      end

      context "returns payment" do
        { payment_method_id: 6,
          payment_method_name: "Boleto Bancario",
          price_payment: 213.21,
          split: 1,
          number_proccess: 718,
          url_payment: "http://checkout.sandbox.tray.com.br/payment/billet/u9uuu8731319u59u3073u9011uu6u6uu"
        }.each do |param, value|
          it param do
            result[:transaction][:payment][param].should == value
          end
        end
      end
    end

    context "with error response" do
      let(:xml) { body_for :get_failure_not_found }
      let(:result) { parser.response(xml) }

      it "does not return success" do
        result[:success].should be_false
      end

      context "returns error" do
        { code: "003042",
          message: "Transação não encontrada"
        }.each do |param, value|
          it param do
            result[:errors].first[param].should == value
          end
        end
      end
    end

    context "with validation error response" do
      let(:xml) { body_for :create_failure_validation_errors }
      let(:result) { parser.response(xml) }

      it "does not return success" do
        result[:success].should be_false
      end

      context "returns error" do
        { code: "1",
          message: "não pode ficar em branco",
          message_complete: "Tipo não pode ficar em branco",
          field: "person_addresses.type_address"
        }.each do |param, value|
          it param do
            result[:errors].first[param].should == value
          end
        end
      end
    end
  end
end
