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

  describe "#valid?" do
    context 'when token account is valid/exists' do
      let(:account) { Tray::Checkout::Account.new(token_account) }

      before do
        VCR.use_cassette 'model/valid_token' do
          @response = account.valid?
        end
      end

      it 'returns true' do
        @response.should be_true
      end
    end

    context "when token account is not valid/doesn't exists" do
      let(:account) { Tray::Checkout::Account.new('4567') }

      before do
        VCR.use_cassette 'model/invalid_token' do
          @response = account.valid?
        end
      end

      it 'returns false' do
        @response.should be_false
      end
    end
  end

  describe "#get_info" do
    context 'when token account is valid/exists' do
      let(:account) { Tray::Checkout::Account.new(token_account) }

      before do
        VCR.use_cassette 'model/valid_token' do
          @response = account.get_info
        end
      end

      it 'response has name attribute' do
        @response.people[:name].should == 'Vendedor Loja Modelo '
      end

      it 'response has service_contact attribute' do
        @response.service_contact.should_not be_blank
      end
    end

    context "when token account is not valid/doesn't exists" do
      let(:account) { Tray::Checkout::Account.new('4567') }

      before do
        VCR.use_cassette 'model/invalid_token' do
          @response = account.get_info
        end
      end

      it 'returns false' do
        @response.success?.should be_false
      end
    end
  end
end
