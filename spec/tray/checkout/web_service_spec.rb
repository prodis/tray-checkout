# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::WebService do
  describe "#request!" do
    let(:web_service) { Tray::Checkout::WebService.new() }

    it "returns XML response" do
      mock_request_for("<xml><fake></fake>")
      url = Tray::Checkout::Transaction::URL
      params = { token: "qwe123asd456poi098lkj765" }
      web_service.request!(url, params).should eql "<xml><fake></fake>"
    end
  end
end

