# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::Account do
  let(:token_account) { '8bfe5ddcb77207b' }

  before :all do
    Tray::Checkout.environment = :sandbox
  end

  after :all do
    Tray::Checkout.environment = :production
  end

  describe "#get_by_token" do
    let(:account) { Tray::Checkout::Account.new }

    context 'when token account is valid/exists' do
      before do
        VCR.use_cassette 'model/valid_token' do
          @response = account.get_by_token(token_account)
        end
      end

      it 'response returns true' do
        @response.success?.should be_true
      end

      it 'response has name attribute' do
        @response.people[:name].should == 'Vendedor Loja Modelo '
      end

      it 'response has service_contact attribute' do
        @response.service_contact.should_not be_blank
      end
    end

    context "when token account is not valid/doesn't exists" do
      before do
        VCR.use_cassette 'model/invalid_token' do
          @response = account.get_by_token("9q8w7e6r5t")
        end
      end

      it 'response returns false' do
        @response.success?.should be_false
      end
    end
  end
end
