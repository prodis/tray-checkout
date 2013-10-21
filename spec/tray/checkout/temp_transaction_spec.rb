# encoding: UTF-8
require 'spec_helper'

describe Tray::Checkout::TempTransaction do
  let(:token) { 'a906bf32cb59060dfc90769524f99d5a' }
  let(:transaction) { Tray::Checkout::TempTransaction.new }
  let(:params) {
    {
      token_account: "8bfe5ddcb77207b",
      postal_code_seller: "18523698",
      transaction: {
        order_number: "1234567",
        free: "Texto Interno",
        url_notification: "http://prodis.blog.br/tray_notification",
        products: [
          {
            code: "teste",
            description: "Notebook Branco",
            quantity: "1",
            price_unit: "2199.99",
            weight: "300",
            url_img: "http://catnross.com/wp-content/uploads/2011/08/product1.jpg"
          }
        ]
      }
    }
  }

  before :all do
    Tray::Checkout.environment = :sandbox
  end

  after :all do
    Tray::Checkout.environment = :production
  end

  describe "#cart_url" do
    context 'when there is a cart created' do
      let(:transaction) { Tray::Checkout::TempTransaction.new(token) }

      it 'returns the URL' do
        url = transaction.cart_url

        url.should == "http://checkout.sandbox.tray.com.br/payment/car/v1/#{token}"
      end
    end

    context "when there is no cart created" do
      it 'returns nil' do
        url = transaction.cart_url

        url.should == nil
      end
    end
  end

  describe '#add_to_cart' do
    context 'when there is a cart created' do
      let(:transaction) { Tray::Checkout::TempTransaction.new(token) }

      it 'updates the same cart' do
        response = ''

        params['token_transaction'] = token

        VCR.use_cassette 'model/update_cart' do
          response = transaction.add_to_cart(params)
        end

        response.transaction[:token].should == token
      end
    end

    context "when there is no cart created" do
      it 'creates a cart and stores the token' do
        response = ''

        VCR.use_cassette 'model/create_cart' do
          response = transaction.add_to_cart(params)
        end

        response.transaction[:token].should_not == token
      end
    end
  end
end
