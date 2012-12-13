# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Parser do
  let(:parser) { Tray::Checkout::Parser.new }

  describe "#response" do
    before :each do
      @xml = body_for(:get_success_boleto)
      @response_parser = Tray::Checkout::ResponseParser.new(@xml)
      @response = Tray::Checkout::Response.new
      Tray::Checkout::ResponseParser.stub(:new).and_return(@response_parser)
    end

    it "creates response parser" do
      Tray::Checkout::ResponseParser.should_receive(:new).with(@xml)
      parser.response(@xml)
    end

    it "parses response" do
      @response_parser.should_receive(:parse).and_return(@response)
      parser.response(@xml).should == @response
    end
  end

  describe "#transaction_params" do
    before :each do
      @params = {
        token_account: "949u5uu9ef36f7u",
        customer: { name: "Pedro Bonamides", sex: :male },
        payment: { payment_method: :boleto_bancario }
      }
      @transaction_params = {
        token_account: "949u5uu9ef36f7u",
        customer: { name: "Pedro Bonamides", sex: :male, gender: "M" },
        payment: { payment_method: :boleto, payment_method_id: "6" }
      }
      @transaction_params_parser = Tray::Checkout::TransactionParamsParser.new(@params)
      Tray::Checkout::TransactionParamsParser.stub(:new).and_return(@transaction_params_parser)
    end

    it "creates transaction params parser" do
      Tray::Checkout::TransactionParamsParser.should_receive(:new).with(@params)
      parser.transaction_params(@params)
    end

    it "parses params" do
      @transaction_params_parser.should_receive(:parse).and_return(@transaction_params)
      parser.transaction_params(@params).should == @transaction_params
    end
  end
end
