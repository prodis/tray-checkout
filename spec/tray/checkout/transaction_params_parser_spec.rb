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

    it "sets customer address type expect API value" do
      transaction_params[:customer][:addresses][0][:type_address].should == "B"
      transaction_params[:customer][:addresses][1][:type_address].should == "D"
    end

    it "sets payment method ID expect API value" do
      transaction_params[:payment][:payment_method_id].should == 4
    end
  end
end
