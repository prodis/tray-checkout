# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Transaction do
  let(:transaction) { Tray::Checkout::Transaction.new }

  describe "#get" do
    context "when transaction is found" do
      before :each do
        mock_request_for(:get_success_boleto)
        @txn = transaction.get("522045453u5uu32e0u8014f060uuu5uu")
      end

      it "returns success" do
        @txn[:success].should be_true
      end

      it "returns transaction data" do
        @txn[:transaction_token].should == "522045453u5uu32e0u8014f060uuu5uu"
        @txn[:transaction_id].should == 501
      end

      it "returns payment data" do
        @txn[:payment][:payment_method_name].should == "Boleto Bancario"
        @txn[:payment][:url_payment].should == "http://checkout.sandbox.tray.com.br/payment/billet/u9uuu8731319u59u3073u9011uu6u6uu"
      end
    end

    context "when transaction is not found" do
      before :each do
        mock_request_for(:get_failure_not_found)
        @txn = transaction.get("987asd654lkj321qwe098poi")
      end

      it "does not return success" do
        @txn[:success].should be_false
      end

      it "returns errors" do
        @txn[:errors].first[:code].should == "003042"
        @txn[:errors].first[:message].should == "Transação não encontrada"
      end
    end
  end

  describe "#create" do
    context "successful" do
      before :each do
        mock_request_for(:create_success_mastercard)
        @txn = transaction.create(fake: "fake params")
      end

      it "returns success" do
        @txn[:success].should be_true
      end

      it "returns transaction data" do
        @txn[:transaction_token].should == "u522169ce59763uu717160u4u1183u43"
        @txn[:status].should == :approved
        @txn[:payment_method].should == :mastercard
      end
    end

    context "unsuccess" do
      before :each do
        mock_request_for(:create_failure_validation_errors)
        @txn = transaction.create(fake: "fake params")
      end

      it "does not return success" do
        @txn[:success].should be_false
      end

      it "returns error" do
        @txn[:errors].first[:code].should == "1"
        @txn[:errors].first[:message].should == "não pode ficar em branco"
        @txn[:errors].first[:message_complete].should == "Tipo não pode ficar em branco"
      end
    end
  end
end
