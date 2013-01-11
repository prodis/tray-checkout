# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::TransactionParamsParser do
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

  let(:parser) { Tray::Checkout::TransactionParamsParser.new(params) }
  let(:transaction_params) { parser.parse }

  describe "#parse" do
    it "sets customer gender expect API value" do
      transaction_params[:customer][:gender].should == "M"
    end

    it "sets customer relationship expect API value" do
      transaction_params[:customer][:relationship].should == "S"
    end

    it "sets customer contact type expect API value" do
      transaction_params[:customer][:contacts][0][:type_contact].should == "H"
      transaction_params[:customer][:contacts][1][:type_contact].should == "M"
      transaction_params[:customer][:contacts][2][:type_contact].should == "W"
    end

    it "sets customer contact number expect API value" do
      transaction_params[:customer][:contacts][0][:number_contact].should == "1142360873"
      transaction_params[:customer][:contacts][1][:number_contact].should == "11987654321"
      transaction_params[:customer][:contacts][2][:number_contact].should == "1134567890"
    end

    it "sets customer address type expect API value" do
      transaction_params[:customer][:addresses][0][:type_address].should == "B"
      transaction_params[:customer][:addresses][1][:type_address].should == "D"
    end

    it "sets payment method ID expect API value" do
      transaction_params[:payment][:payment_method_id].should == 4
    end

    { card_name: "ZEFINHA NOCEGA",
      card_number: "5105105105105100",
      card_expdate_month: "09",
      card_expdate_year: "2015",
      card_cvv: "123"
    }.each do |param, value|
      it "sets payment #{param}" do
        transaction_params[:payment][param].should == value
      end
    end

    it "sets products as expect API data structure" do
      transaction_params[:transaction_product][0][:code].should == "LOGO-8278"
      transaction_params[:transaction_product][0][:quantity].should == 2
      transaction_params[:transaction_product][0][:price_unit].should == 100.99
      transaction_params[:transaction_product][0][:description].should == "Logo Prodis"

      transaction_params[:transaction_product][1][:code].should == "877"
      transaction_params[:transaction_product][1][:quantity].should == 1
      transaction_params[:transaction_product][1][:price_unit].should == 10.00
      transaction_params[:transaction_product][1][:description].should == "Outro produto"
    end

    it "keeps token account supplied in params" do
      transaction_params[:token_account].should == params[:token_account]
    end

    context "when sets token account in configuration" do
      around do |example|
        Tray::Checkout.configure { |config| config.token_account = "1q2w3e4r5t6y7u8" }
        example.run
        Tray::Checkout.configure { |config| config.token_account = nil }
      end

      context "and token account is supplied in params" do
        it "keeps token account supplied in params" do
          transaction_params[:token_account].should == params[:token_account]
        end
      end

      context "and token account is not supplied in params" do
        it "uses token account from configuration" do
          params.delete(:token_account)
          transaction_params = Tray::Checkout::TransactionParamsParser.new(params).parse
          transaction_params[:token_account].should == "1q2w3e4r5t6y7u8"
        end
      end
    end
  end
end
