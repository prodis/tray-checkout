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
end
