# encoding: UTF-8
module Tray
  module Checkout
    class Account < Tray::Checkout::BaseService
      def api_url
        "#{Tray::Checkout.api_url}/api/people/"
      end

      def get_by_token(token)
        request("get_seller_or_company", { token_account: token || Tray::Checkout::token_account })
      end
    end
  end
end
