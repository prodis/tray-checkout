# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Transaction do
  let(:transaction) { Tray::Checkout::Transaction.new }

  describe "#get" do
    context "when transaction is found" do
      before :each do
        mock_request_for(:get_success_boleto)
        @result = transaction.get("522045453u5uu32e0u8014f060uuu5uu")
      end

      it "returns success" do
        @result[:success].should be_true
      end

      it "returns transaction data" do
        @result[:transaction_token].should == "522045453u5uu32e0u8014f060uuu5uu"
        @result[:transaction_id].should == 501
      end

      it "returns payment data" do
        @result[:payment][:payment_method_name].should == "Boleto Bancario"
        @result[:payment][:url_payment].should == "http://checkout.sandbox.tray.com.br/payment/billet/u9uuu8731319u59u3073u9011uu6u6uu"
      end
    end

    context "when transaction is not found" do
      before :each do
        mock_request_for(:get_failure_not_found)
        @result = transaction.get("987asd654lkj321qwe098poi")
      end

      it "does not return success" do
        @result[:success].should be_false
      end

      it "returns errors" do
        @result[:errors].first[:code].should == "003042"
        @result[:errors].first[:message].should == "Transação não encontrada"
      end
    end
  end

  describe "#create" do
    context "successful" do
      before :each do
        mock_request_for(:create_success_mastercard)
        @result = transaction.create(fake: "fake params")
      end

      it "returns success" do
        @result[:success].should be_true
      end

      it "returns transaction data" do
        @result[:transaction_token].should == "u522169ce59763uu717160u4u1183u43"
        @result[:status].should == :approved
        @result[:payment_method].should == :mastercard
      end
    end

    context "unsuccess" do
      before :each do
        mock_request_for(:create_failure_validation_errors)
        @result = transaction.create(fake: "fake params")
      end

      it "does not return success" do
        @result[:success].should be_false
      end

      it "returns error" do
        @result[:errors].first[:code].should == "1"
        @result[:errors].first[:message].should == "não pode ficar em branco"
        @result[:errors].first[:message_complete].should == "Tipo não pode ficar em branco"
      end
    end
  end
end
