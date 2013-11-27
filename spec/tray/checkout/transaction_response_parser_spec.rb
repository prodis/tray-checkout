# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::TransactionResponseParser do
  describe "#parse" do
    context "with success response from temp_transaction" do
      let(:xml) { body_for :create_temp_transaction_with_token }
      let(:parser) { Tray::Checkout::TransactionResponseParser.new(xml) }
      let(:response) { parser.parse }

      it "returns success" do
        response.success?.should be_true
      end

      context "returns transaction" do
        {
          token: "a906bf32cb59060dfc90769524f99d5a",
          url_car: "\n\t\t\thttp://checkout.sandbox.tray.com.br/payment/car/v1/\n\t\t"
        }.each do |param, value|
          it param do
            response.transaction[param].should == value
          end
        end
      end

      context "returns products" do
        {
          code: "teste",
          img: "\n\t\t\t\t\thttp://catnross.com/wp-content/uploads/2011/08/product1.jpg\n\t\t\t\t",
          sku_code: nil,
          description: "produto teste",
          extra: nil,
          id: 4502,
          type_product: nil
        }.each do |param, value|
          it param do
            response.transaction[:products].first[param].should == value
          end
        end

        {
          price_unit: "10.0",
          quantity: "5.0",
          weight: "300.0"
        }.each do |param, value|
          it param do
            response.transaction[:products].first[param].to_s.should == value
          end
        end
      end
    end

    context "with success response" do
      let(:xml) { body_for :get_success_boleto }
      let(:parser) { Tray::Checkout::TransactionResponseParser.new(xml) }
      let(:response) { parser.parse }

      it "returns success" do
        response.success?.should be_true
      end

      it "returns empty errors" do
        response.errors.should be_empty
      end

      context "returns transaction" do
        {
          order_number: "1234567",
          free: "Texto Interno",
          status_name: "Em Recupera\\xC3\\xA7\\xC3\\xA3o",
          status: :recovering,
          id: 3856,
          token: "4761d2e198ba6b60b45900a4d95482d5"
        }.each do |param, value|
          it param do
            response.transaction[param].should == value
          end
        end
      end

      context "returns payment" do
        {
          tid: nil,
          split: 1,
          linha_digitavel: "34191.76007 00536.260144 50565.600009 6 58630000219999",
          method: :boleto,
          method_name: "Boleto Bancario"
        }.each do |param, value|
          it param do
            response.payment[param].should == value
          end
        end

        {
          price_original: '2199.99',
          price: '2199.99'
        }.each do |param, value|
          it param do
            response.payment[param].to_s.should == value
          end
        end
      end

      context "returns customer" do
        {
          name: "Nome do Cliente",
          cpf: "98489882380",
          email: "emaildo@cliente.com.br",
          company_name: nil,
          trade_name: nil,
          cnpj: nil
        }.each do |param, value|
          it param do
            response.customer[param].should == value
          end
        end

        context "address with" do
          {
            street: "Av Paulista",
            number: "1001",
            neighborhood: "Centro",
            postal_code: "04001001",
            completion: nil,
            city: "S\\xC3\\xA3o Paulo",
            state: "SP"
          }.each do |param, value|
            it param do
              response.customer[:addresses].first[param].should == value
            end
          end
        end

        context "contacts with" do
          [ {
              number: "11998761234",
              id: nil,
              type: :mobile
            }
          ].each_with_index do |contacts, i|
            contacts.each do |param, value|
              it param do
                response.customer[:contacts][i][param].should == value
              end
            end
          end
        end

        context "without contacts" do
          it "returns empty array" do
            parser = Tray::Checkout::TransactionResponseParser.new(body_for(:get_success_boleto_without_contacts))
            response = parser.parse
            response.customer[:contacts].should == []
          end
        end
      end
    end

    context "with error response" do
      let(:xml) { body_for :get_failure_not_found }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse  }

      [:transaction, :payment, :customer].each do |info|
        it "returns nil #{info}" do
          response.send(info).should be_nil
        end
      end
    end

    context "with validation error response" do
      let(:xml) { body_for :create_failure_validation_errors }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse  }

      [:transaction, :payment, :customer].each do |info|
        it "returns nil #{info}" do
          response.send(info).should be_nil
        end
      end
    end
  end
end
