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
          payment_method: :boleto,
          payment_method_id: 6,
          payment_method_name: "Boleto Bancario",
          status: :waiting_payment,
          status_id: 4,
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
          url_notification: "http://prodis.blog.br/tray_notification",
          seller_token: "949u5uu9ef36f7u"
        }.each do |param, value|
          it param do
            result[param].should == value
          end
        end

        it "date_transaction" do
          date_transaction = result[:date_transaction]
          date_transaction.should be_a(Time)
          date_transaction.to_s.should == "2012-12-03 18:08:37 UTC"
        end
      end

      context "returns payment" do
        { payment_method: :boleto,
          payment_method_id: 6,
          payment_method_name: "Boleto Bancario",
          price_payment: 213.21,
          split: 1,
          number_proccess: 718,
          url_payment: "http://checkout.sandbox.tray.com.br/payment/billet/u9uuu8731319u59u3073u9011uu6u6uu"
        }.each do |param, value|
          it param do
            result[:payment][param].should == value
          end
        end

        it "date_approval" do
          date_approval = result[:payment][:date_approval]
          date_approval.should be_a(Time)
          date_approval.to_s.should == "2012-12-04 00:55:15 UTC"
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

  describe "#payment_params!" do
    let :params do
      {
        token_account: "949u5uu9ef36f7u",
        customer: {
          name: "Pedro Bonamides",
          cpf: "18565842673",
          email: "pedro@bo.com.br",
          sex: :male,
          marital_status: :single,
          contacts: [
            { contact_type: :home,
              number_contact: "1142360873"
            },
            { contact_type: :mobile,
              number_contact: "11987654321"
            },
            { contact_type: :work,
              number_contact: "1134567890"
            }
          ],
          addresses: [
            { address_type: :billing,
              street: "Avenida Pedro Alvares Cabral",
              number: "123",
              neighborhood: "Parque Ibirapuera",
              postal_code: "04094050",
              city: "São Paulo",
              state: "SP"
            },
            { address_type: :delivery,
              street: "Avenida Pedro Alvares Cabral",
              number: "123",
              neighborhood: "Parque Ibirapuera",
              postal_code: "04094050",
              city: "São Paulo",
              state: "SP"
            }
          ]
        },
        transaction: {
          order_number: "R1245",
          shipping_type: "Sedex",
          shipping_price: 13.94,
          url_notification: "http://prodis.blog.br/tray_notification"
        },
        transaction_product: [
          { code: "LOGO-8278",
            quantity: 2,
            price_unit: 100.99,
            description: "Logo Prodis"
          }
        ],
        payment: {
          payment_method: :mastercard,
          split: 3,
          card_name: "ZEFINHA NOCEGA",
          card_number: "5105105105105100",
          card_expdate_month: "09",
          card_expdate_year: "2015",
          card_cvv: "123"
        }
      }
    end

    let(:result) { parser.payment_params!(params) }

    it "sets customer gender expect API value" do
      result[:customer][:gender].should == "M"
    end

    it "sets customer relationship expect API value" do
      result[:customer][:relationship].should == "S"
    end

    it "sets customer contact type expect API value" do
      result[:customer][:contacts][0][:type_contact].should == "H"
      result[:customer][:contacts][1][:type_contact].should == "M"
      result[:customer][:contacts][2][:type_contact].should == "W"
    end

    it "sets customer address type expect API value" do
      result[:customer][:addresses][0][:type_address].should == "B"
      result[:customer][:addresses][1][:type_address].should == "D"
    end

    it "sets payment method ID expect API value" do
      result[:payment][:payment_method_id].should == 4
    end
  end
end
