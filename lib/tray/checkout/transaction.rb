# encoding: UTF-8
module Tray
  module Checkout
    class Transaction < Tray::Checkout::BaseService
      def api_url
        "#{Tray::Checkout.api_url}/v2/transactions/"
      end

      def get(token, account=nil)
        account ||= Tray::Checkout.token_account
        request("get_by_token", { token_account: account, token_transaction: token })
      end

      def create(params)
        request("pay_complete", parser.response_params(params))
      end
    end
  end
end
