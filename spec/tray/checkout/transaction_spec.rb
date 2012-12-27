# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Transaction do
  let(:transaction) { Tray::Checkout::Transaction.new }

  describe "#get" do
    context "when transaction is found" do
      before :each do
        mock_request_for(:get_success_boleto)
        @response = transaction.get("db9b3265af6e7e19af8dd70e00d77383x")
      end

      it "returns success" do
        @response.success?.should be_true
      end

      it "returns transaction data" do
        @response.transaction[:token].should == "db9b3265af6e7e19af8dd70e00d77383x"
        @response.transaction[:id].should == 530
      end

      it "returns payment data" do
        @response.payment[:method_name].should == "Boleto Bancario"
        @response.payment[:url].should == "http://checkout.sandbox.tray.com.br/payment/billet/d2baa84c13f23addde401c8e1426396e"
      end

      it "returns customer data" do
        @response.customer[:name].should == "Pedro Bonamides"
        @response.customer[:email].should == "pedro@bo.com.br"
      end
    end

    context "when transaction is not found" do
      before :each do
        mock_request_for(:get_failure_not_found)
        @response = transaction.get("987asd654lkj321qwe098poi")
      end

      it "does not return success" do
        @response.success?.should be_false
      end

      it "returns errors" do
        @response.errors.first[:code].should == "003042"
        @response.errors.first[:message].should == "Transação não encontrada"
      end
    end
  end

  describe "#create" do
    context "successful" do
      before :each do
        mock_request_for(:create_success_mastercard)
        @response = transaction.create(fake: "fake params")
      end

      it "returns success" do
        @response.success?.should be_true
      end

      it "returns transaction data" do
        @response.transaction[:token].should == "fc739f786425e34010481dcc2939e4bdx"
        @response.transaction[:status].should == :approved
      end

      it "returns payment data" do
        @response.payment[:method].should == :mastercard
        @response.payment[:tid].should == "1355409331"
      end

      it "returns customer data" do
        @response.customer[:name].should == "Pedro Bonamides"
        @response.customer[:email].should == "pedro@bo.com.br"
      end
    end

    context "unsuccess" do
      before :each do
        mock_request_for(:create_failure_validation_errors)
        @response = transaction.create(fake: "fake params")
      end

      it "does not return success" do
        @response.success?.should be_false
      end

      it "returns error" do
        @response.errors.first[:code].should == "1"
        @response.errors.first[:message].should == "não pode ficar em branco"
        @response.errors.first[:message_complete].should == "Tipo não pode ficar em branco"
      end
    end
  end
end
