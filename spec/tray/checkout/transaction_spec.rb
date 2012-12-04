# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Transaction do
  let(:transaction) { Tray::Checkout::Transaction.new }

  describe "#get" do
    context "when transaction is found" do
      before(:each) { mock_request_for(:get_success_boleto) }

      it "returns success" do
        pending
        result = transaction.get("522045453u5uu32e0u8014f060uuu5uu")
        result[:success].should be_true
      end

      it "returns transaction data" do
        result = transaction.get("522045453u5uu32e0u8014f060uuu5uu")

        result[:transaction][:transaction_token].should == "522045453u5uu32e0u8014f060uuu5uu"
        result[:transaction][:transaction_id].should == 501
        result[:transaction][:payment_method_id].should == 6 #TODO: Symbol
        result[:transaction][:payment_method_name].should == "Boleto Bancario"
        result[:transaction][:status_id].should == 4 #TODO: Symbol
        result[:transaction][:status_name].should == "Aguardando Pagamento"
        result[:transaction][:order_number].should == "R1240"
        result[:transaction][:price_original].should == 213.21
        result[:transaction][:price_payment].should == 213.21
        result[:transaction][:price_seller].should == 199.19
        result[:transaction][:shipping_type].should == "Sedex"
        result[:transaction][:shipping_price].should == 1.23
        result[:transaction][:split].should == 1
        result[:transaction][:date_transaction].should == "2012-12-03T18:08:37" #TODO: DateTime
      end

      it "returns payment data" do
        result = transaction.get("522045453u5uu32e0u8014f060uuu5uu")

        payment = result[:transaction][:payment]
        payment[:payment_method_id].should == 6 #TODO: Symbol
        payment[:payment_method_name].should == "Boleto Bancario"
        payment[:price_payment].should == 213.21
        payment[:url_payment].should == "http://checkout.sandbox.tray.com.br/payment/billet/f9bfe8731319b59e3073a9011de6b6db"
        payment[:number_proccess].should == 718
        payment[:split].should == 1
      end
    end
  end

  context "when transaction is not found" do
    before(:each) { mock_request_for(:get_failure_not_found) }

    it "does not return success" do
      pending
      result = transaction.get("987asd654lkj321qwe098poi")
      result[:success].should be_false
    end

    it "returns errors" do
      result = transaction.get("987asd654lkj321qwe098poi")

      result[:errors].should be_a(Array)
      result[:errors].first[:code].should == "003042"
      result[:errors].first[:message].should == "Transação não encontrada"
    end
  end
end
