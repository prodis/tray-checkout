# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::ParamsParser do
  context 'transaction' do
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
            { type: :home,   number: "1142360873"  },
            { type: :mobile, number: "11987654321" },
            { type: :work,   number: "1134567890"  }
          ],
          addresses: [
            { type: :billing,
              street: "Avenida Pedro Alvares Cabral",
              number: "123",
              neighborhood: "Parque Ibirapuera",
              postal_code: "04094050",
              city: "São Paulo",
              state: "SP"
            },
            { type: :delivery,
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
          url_notification: "http://prodis.blog.br/tray_notification",
          url_img: "http://prodis.net.br/images/prodis_150.gif",
          products: [
            { code: "LOGO-8278",
              quantity: 2,
              price_unit: 100.99,
              description: "Logo Prodis"
            },
            { code: "877",
              quantity: 1,
              price_unit: 10.00,
              description: "Outro produto"
            }
          ]
        },
        payment: {
          method: :mastercard,
          split: 3,
          card: {
            name: "ZEFINHA NOCEGA",
            number: "5105105105105100",
            expdate_month: "09",
            expdate_year: "2015",
            cvv: "123"
          }
        }
      }
    end

    let(:parser) { Tray::Checkout::ParamsParser.new(params) }
    let(:response_params) { parser.parse }

    describe "#parse" do
      context "when transaction has image URL" do
        it "keeps image URL parameter" do
          response_params[:transaction][:url_img].should == params[:transaction][:url_img]
        end
      end

      context "when image URL is nil" do
        it "removes image URL parameter" do
          params[:transaction][:url_img] = nil
          response_params[:transaction].has_key?(:url_img).should eq false
        end
      end

      it "sets customer gender expect API value" do
        response_params[:customer][:gender].should == "M"
      end

      it "sets customer relationship expect API value" do
        response_params[:customer][:relationship].should == "S"
      end

      it "sets customer contact type expect API value" do
        response_params[:customer][:contacts][0][:type_contact].should == "H"
        response_params[:customer][:contacts][1][:type_contact].should == "M"
        response_params[:customer][:contacts][2][:type_contact].should == "W"
      end

      it "sets customer contact number expect API value" do
        response_params[:customer][:contacts][0][:number_contact].should == "1142360873"
        response_params[:customer][:contacts][1][:number_contact].should == "11987654321"
        response_params[:customer][:contacts][2][:number_contact].should == "1134567890"
      end

      it "sets customer address type expect API value" do
        response_params[:customer][:addresses][0][:type_address].should == "B"
        response_params[:customer][:addresses][1][:type_address].should == "D"
      end

      it "sets payment method ID expect API value" do
        response_params[:payment][:payment_method_id].should == 4
      end

      { card_name: "ZEFINHA NOCEGA",
        card_number: "5105105105105100",
        card_expdate_month: "09",
        card_expdate_year: "2015",
        card_cvv: "123"
      }.each do |param, value|
        it "sets payment #{param}" do
          response_params[:payment][param].should == value
        end
      end

      it "sets products as expect API data structure" do
        response_params[:transaction_product][0][:code].should == "LOGO-8278"
        response_params[:transaction_product][0][:quantity].should == 2
        response_params[:transaction_product][0][:price_unit].should == 100.99
        response_params[:transaction_product][0][:description].should == "Logo Prodis"

        response_params[:transaction_product][1][:code].should == "877"
        response_params[:transaction_product][1][:quantity].should == 1
        response_params[:transaction_product][1][:price_unit].should == 10.00
        response_params[:transaction_product][1][:description].should == "Outro produto"
      end

      it "keeps token account supplied in params" do
        response_params[:token_account].should == params[:token_account]
      end

      context "when sets token account in configuration" do
        around do |example|
          Tray::Checkout.configure { |config| config.token_account = "1q2w3e4r5t6y7u8" }
          example.run
          Tray::Checkout.configure { |config| config.token_account = nil }
        end

        context "and token account is supplied in params" do
          it "keeps token account supplied in params" do
            response_params[:token_account].should == params[:token_account]
          end
        end

        context "and token account is not supplied in params" do
          it "uses token account from configuration" do
            params.delete(:token_account)
            response_params = Tray::Checkout::ParamsParser.new(params).parse
            response_params[:token_account].should == "1q2w3e4r5t6y7u8"
          end
        end
      end
    end
  end

  context 'account' do
    let :params do
      {
        contact_primary: "08000059230",
        name: "Vendedor Loja Modelo",
        trade_name: "Loja Modelo",
        email: "lojamodelo@tray.com.br",
        url_logo: nil,
        css_url: "http://default.com/default.css",
        service_contact: {
          service_phone: "(14)3412-1377",
          email_service: "lojamodelo@tray.com.br",
          service_phone_status: "true",
          email_service_status: "true"
        },
        seconds_redirect: nil
      }
    end

    let(:parser) { Tray::Checkout::ParamsParser.new(params) }
    let(:account_params) { parser.parse }

    describe "#parse" do
      it "sets service_contact expect API value" do
        account_params[:service_contact][:service_phone].should == "(14)3412-1377"
        account_params[:service_contact][:email_service].should == "lojamodelo@tray.com.br"
        account_params[:service_contact][:service_phone_status].should == "true"
        account_params[:service_contact][:email_service_status].should == "true"
      end

      it "sets seconds_redirect expect API value" do
        account_params[:seconds_redirect].should be_nil
      end
    end
  end
end
