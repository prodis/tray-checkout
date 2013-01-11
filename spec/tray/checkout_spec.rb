# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout do
  describe "#request_timeout" do
    it "default is 5" do
      Tray::Checkout.request_timeout.should eql 5
    end

    context "when set timeout" do
      it "returns timeout" do
        Tray::Checkout.configure { |config| config.request_timeout = 3 }
        Tray::Checkout.request_timeout.should eql 3
      end

      it "returns timeout in seconds (integer)" do
        Tray::Checkout.configure { |config| config.request_timeout = 2.123 }
        Tray::Checkout.request_timeout.should eql 2
      end
    end
  end

  describe "#token_account" do
    it "default is nil" do
      Tray::Checkout.token_account.should be_nil
    end

    context "when set token account" do
      around do |example|
        Tray::Checkout.configure { |config| config.token_account = "123u5uu9ef36f7u" }
        example.run
        Tray::Checkout.configure { |config| config.token_account = nil }
      end

      it "returns token account" do
        Tray::Checkout.token_account.should == "123u5uu9ef36f7u"
      end
    end
  end

  describe "#environment" do
    it "default is production" do
      Tray::Checkout.environment.should == :production
    end

    { production: "https://api.checkout.tray.com.br/api/transactions",
      sandbox:    "http://api.sandbox.checkout.tray.com.br/api/v1/transactions"
    }.each do |environment, url|
      context "when environment is #{environment}" do
        around do |example|
          Tray::Checkout.configure { |config| config.environment = environment }
          example.run
          Tray::Checkout.configure { |config| config.environment = :production }
        end

        it "returns correct API URL" do
          Tray::Checkout.api_url.should == url
        end
      end
    end
  end
end
