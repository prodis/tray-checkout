# encoding: UTF-8
module Tray
  module Checkout
    class Transaction < Tray::Checkout::BaseService
      def get(token_transaction, token_account = nil)
        request("get_by_token", {
          token_account: token_account ||= Tray::Checkout.token_account,
          token_transaction: token_transaction
        })
      end

      def create(params)
        request("pay_complete", parser.response_params(params))
      end

      protected

      def api_url
        "#{Tray::Checkout.api_url}/v2/transactions/"
      end
    end
  end
end
