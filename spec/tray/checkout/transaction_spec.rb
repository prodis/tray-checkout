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
        @result[:transaction][:transaction_token].should == "522045453u5uu32e0u8014f060uuu5uu"
        @result[:transaction][:transaction_id].should == 501
      end

      it "returns payment data" do
        payment = @result[:transaction][:payment]
        payment[:payment_method_name].should == "Boleto Bancario"
        payment[:url_payment].should == "http://checkout.sandbox.tray.com.br/payment/billet/u9uuu8731319u59u3073u9011uu6u6uu"
      end
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
