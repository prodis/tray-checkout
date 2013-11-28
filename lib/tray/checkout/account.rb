# encoding: UTF-8
module Tray
  module Checkout
    class Account < Tray::Checkout::BaseService
      def api_url
        "#{Tray::Checkout.api_url}/api/people/"
      end

      def initialize(account=nil)
        @account = account || Tray::Checkout.token_account
      end

      def get_info_by_token
        request("get_seller_or_company", { token_account: @account })
      end
    end
  end
end
