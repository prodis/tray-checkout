# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Transaction do
  let(:transaction) { Tray::Checkout::Transaction.new }
  let(:params) {
    {
      token_account: "8bfe5ddcb77207b",
      customer: {
        name: "Nome do Cliente",
        cpf: "12312312312",
        email: "emaildo@cliente.com.br",
        birth_date: '01/01/1900'.to_date,
        sex: :male,
        marital_status: :single,
        contacts: [
          { type: :mobile,
            number: "11998761234"
          }
        ],
        addresses: [
          { type: :billing,
            street: "Av Paulista",
            number: "1001",
            neighborhood: "Centro",
            postal_code: "04001001",
            completion: "apto 11",
            city: "São Paulo",
            state: "SP"
          }
        ]
      },
      transaction: {
        available_payment_methods: '6',
        order_number: "123456789",
        shipping_type: "Sedex",
        shipping_price: "15.00",
        price_discount: "1.00",
        price_additional: "1.00",
        url_notification: "http://prodis.blog.br/tray_notification",
        free: "Texto Interno",
        sub_store: "2",
        products: [
          {
            description: "Notebook Branco",
            quantity: "1",
            price_unit: "1999.99",
            code: "123",
            sku_code: "72628",
            extra: "Produto novo"
          }
        ]
      },
      payment: {
        method: :mastercard,
        split: 12,
        card_name: "Nome Impresso",
        card_number: "4073020000000002",
        card_expdate_month: "01",
        card_expdate_year: "2017",
        cvv: "123"
      },
      affiliates: [
        {
          email: "affiliates@test.com",
          percentage: "1"
        }
      ]
    }
  }

  before :all do
    Tray::Checkout.environment = :sandbox
  end

  after :all do
    Tray::Checkout.environment = :production
  end

  describe "#get" do
    context "token account is defined on the configuration" do
      around do |example|
        Tray::Checkout.configure { |config| config.token_account = "8bfe5ddcb77207b" }
        example.run
        Tray::Checkout.configure { |config| config.token_account = nil }
      end

      before :each do
        VCR.use_cassette 'model/get_success_boleto' do
          @response = transaction.get("4761d2e198ba6b60b45900a4d95482d5")
        end
      end

      it "returns success" do
        @response.success?.should be true
      end

      it "returns the transaction with only one parameter" do
        @response.transaction[:token].should == "4761d2e198ba6b60b45900a4d95482d5"
      end
    end

    context "when transaction is found" do
      before :each do
        VCR.use_cassette 'model/get_success_boleto' do
          @response = transaction.get("4761d2e198ba6b60b45900a4d95482d5", "8bfe5ddcb77207b")
        end
      end

      it "returns success" do
        @response.success?.should be true
      end

      it "returns transaction data" do
        @response.transaction[:token].should == "4761d2e198ba6b60b45900a4d95482d5"
        @response.transaction[:id].should == 3856
      end

      it "returns payment data" do
        @response.payment[:method_name].should == "Boleto Bancario"
      end

      it "returns customer data" do
        @response.customer[:name].should == "Nome do Cliente"
        @response.customer[:email].should == "emaildo@cliente.com.br"
      end
    end

    context "when transaction is not found" do
      before :each do
        VCR.use_cassette 'model/get_failure_not_found' do
          @response = transaction.get("987asd654lkj321qwe098poi", "8bfe5ddcb77207b")
        end
      end

      it "does not return success" do
        @response.success?.should be false
      end

      it "returns errors" do
        @response.errors.first[:code].should == "003042"
        @response.errors.first[:message].should == "Transação não encontrada"
      end
    end
  end

  describe "#create" do
    context "successful payment slip" do
      before :each do
        VCR.use_cassette 'model/create_success_boleto' do
          new_params = params
          new_params[:payment] = { method: :boleto }

          @response = transaction.create(new_params)
        end
      end

      it "returns success" do
        @response.success?.should be true
      end

      it "returns transaction data" do
        @response.transaction[:token].should == "756c0bb313b7e86caf59cf8f1ddfb281"
        @response.transaction[:status].should == :recovering
      end

      it "returns payment data" do
        @response.payment[:method].should == :boleto
        @response.payment[:tid].should == nil
      end

      it "returns customer data" do
        @response.customer[:name].should == "Nome do Cliente"
      end
    end

    context "successful credit card" do
      before :each do
        VCR.use_cassette 'model/create_success_mastercard' do
          @response = transaction.create(params)
        end
      end

      it "returns success" do
        @response.success?.should be true
      end

      it "returns transaction data" do
        @response.transaction[:token].should == "756c0bb313b7e86caf59cf8f1ddfb281"
        @response.transaction[:status].should == :recovering
      end

      it "returns payment data" do
        @response.payment[:method].should == :mastercard
        @response.payment[:tid].should == '1233'
      end

      it "returns customer data" do
        @response.customer[:name].should == "Nome do Cliente"
      end
    end

    context "unsuccess payment slip" do
      before :each do
        params[:customer][:contacts][0].delete(:type)

        VCR.use_cassette 'model/create_failure_validation_errors' do
          @response = transaction.create(params)
        end
      end

      it "does not return success" do
        @response.success?.should be false
      end

      it "returns error" do
        @response.errors.first[:code].should == "13"
        @response.errors.first[:message].should == "não está incluído na lista"
        @response.errors.first[:message_complete].should == "Tipo de Contato não está incluído na lista"
      end
    end
  end
end
