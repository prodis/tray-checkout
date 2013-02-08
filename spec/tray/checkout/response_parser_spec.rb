# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::ResponseParser do
  describe "#parse" do
    context "with success response" do
      let(:xml) { body_for :get_success_boleto }
      let(:parser) { Tray::Checkout::ResponseParser.new(xml) }
      let(:response) { parser.parse }

      it "returns success" do
        response.success?.should be_true
      end

      it "returns empty errors" do
        response.errors.should be_empty
      end

      context "returns transaction" do
        { token: "db9b3265af6e7e19af8dd70e00d77383x",
          id: 530,
          status: :approved,
          status_name: "Aprovada",
          order_number: "F2456",
          price_original: 33.21,
          price_payment: 33.21,
          price_seller: 30.69,
          price_additional: 0.00,
          price_discount: 0.00,
          shipping_type: "Sedex",
          shipping_price: 1.23,
          split: 1,
          url_notification: "http://prodis.blog.br/tray_notification",
          transaction_token: nil,
          transaction_id: nil,
          status_id: nil
        }.each do |param, value|
          it param do
            response.transaction[param].should == value
          end
        end

        it "date_transaction" do
          date_transaction = response.transaction[:date_transaction]
          date_transaction.should be_a(Time)
          date_transaction.to_s.should == "2012-12-13 02:49:42 UTC"
        end
      end

      context "returns payment" do
        { method: :boleto,
          method_name: "Boleto Bancario",
          price: 33.21,
          split: 1,
          number_proccess: 750,
          response: "Texto de resposta fake.",
          url: "http://checkout.sandbox.tray.com.br/payment/billet/d2baa84c13f23addde401c8e1426396e",
          linha_digitavel: "34191.76007 00075.091140 53021.450001 1 55510000003321",
          payment_method_id: nil,
          payment_method_name: nil,
          price_payment: nil,
          url_payment: nil,
          payment_response: nil
        }.each do |param, value|
          it param do
            response.payment[param].should == value
          end
        end

        { date_approval: "2012-12-15 15:24:38 UTC",
          date_payment: "2012-12-15 15:23:05 UTC"
        }.each do |param, value|
          it param do
            response.payment[param].should be_a(Time)
            response.payment[param].to_s.should == value
          end
        end
      end

      context "returns customer" do
        { name: "Pedro Bonamides",
          email: "pedro@bo.com.br",
          cpf: "18565842673"
        }.each do |param, value|
          it param do
            response.customer[param].should == value
          end
        end

        context "address with" do
          { street: "Avenida Pedro Alvares Cabral",
            number: "123",
            neighborhood: "Parque Ibirapuera",
            postal_code: "04094050",
            completion: nil,
            city: "São Paulo",
            state: "SP"
          }.each do |param, value|
            it param do
              response.customer[:addresses].first[param].should == value
            end
          end
        end

        context "contacts with" do
          [ { id: 345,
              number: "1137654321",
              type: :home,
              primary: true,
              contact_id: nil,
              value: nil,
              type_contact: nil
            },
            { id: 348,
              number: "11987654321",
              type: :mobile,
              primary: false,
              contact_id: nil,
              value: nil,
              type_contact: nil
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
            parser = Tray::Checkout::ResponseParser.new(body_for(:get_success_boleto_without_contacts))
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

      it "does not return success" do
        response.success?.should be_false
      end

      [:transaction, :payment, :customer].each do |info|
        it "returns nil #{info}" do
          response.send(info).should be_nil
        end
      end

      context "returns error" do
        { code: "003042",
          message: "Transação não encontrada"
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
        response.success?.should be_false
      end

      [:transaction, :payment, :customer].each do |info|
        it "returns nil #{info}" do
          response.send(info).should be_nil
        end
      end

      context "returns error" do
        { code: "1",
          message: "não pode ficar em branco",
          message_complete: "Tipo não pode ficar em branco",
          field: "person_addresses.type_address"
        }.each do |param, value|
          it param do
            response.errors.first[param].should == value
          end
        end
      end
    end
  end
end
