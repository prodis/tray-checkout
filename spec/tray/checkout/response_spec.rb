# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Response do
  let(:response) { Tray::Checkout::Response.new }

  describe ".new" do
    it "sets success to false" do
      response.success?.should be false
    end

    it "sets errors to empty" do
      response.errors.should be_empty
    end
  end
end
