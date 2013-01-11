# encoding: UTF-8
require 'active_support/core_ext'
require 'net/https'
require 'uri'

module Tray
  module Checkout
    class WebService
      def request!(url, params)
        uri = URI.parse(url)
        http = build_http(uri)

        request = build_request(uri, params)
        log_request(request, url)

        response = http.request(request)
        log_response(response)

        response.body
      end

      private

      def build_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.ssl?
        http.open_timeout = Tray::Checkout.request_timeout
        http
      end

      def build_request(uri, params)
        request = Net::HTTP::Post.new(uri.path)
        request.body = params.to_param
        request
      end

      def log_request(request, url)
        message = format_message(request) do
          message =  with_line_break { "Tray-Checkout Request:" }
          message << with_line_break { "POST #{url}" }
        end

        Tray::Checkout.log(message)
      end

      def log_response(response)
        message = format_message(response) do
          message =  with_line_break { "Tray-Checkout Response:" }
          message << with_line_break { "HTTP/#{response.http_version} #{response.code} #{response.message}" }
        end

        Tray::Checkout.log(message)
      end

      def format_message(http)
        message = yield
        message << with_line_break { format_headers_for(http) } if Tray::Checkout.log_level == :debug
        message << with_line_break { http.body }
      end

      def format_headers_for(http)
        http.each_header.map { |name, value| "#{name}: #{value}" }.join("\n")
      end

      def with_line_break
        "#{yield}\n"
      end
    end
  end
end
