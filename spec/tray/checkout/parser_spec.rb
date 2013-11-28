# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Parser do
  let(:parser) { Tray::Checkout::Parser.new }

  describe "#response" do
    before :each do
      @xml = body_for(:get_success_mastercard)
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

  describe "#response_params" do
    before :each do
      @params = {
        token_account: "949u5uu9ef36f7u",
        customer: { name: "Pedro Bonamides", sex: :male },
        payment: { payment_method: :boleto_bancario }
      }
      @response_params = {
        token_account: "949u5uu9ef36f7u",
        customer: { name: "Pedro Bonamides", sex: :male, gender: "M" },
        payment: { payment_method: :boleto, payment_method_id: "6" }
      }
      @params_parser = Tray::Checkout::ParamsParser.new(@params)
      Tray::Checkout::ParamsParser.stub(:new).and_return(@params_parser)
    end

    it "creates transaction params parser" do
      Tray::Checkout::ParamsParser.should_receive(:new).with(@params)
      parser.response_params(@params)
    end

    it "parses params" do
      @params_parser.should_receive(:parse).and_return(@response_params)
      parser.response_params(@params).should == @response_params
    end
  end
end
