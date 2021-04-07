require 'rack/utils'
require 'openssl'

module Camo
  class Server
    include HeadersUtils

    attr_reader :request

    def call(env)
      build_request(env)

      return [404, default_response_headers, []] unless request.method == 'GET'
      return [401, default_response_headers, ['Invalid digest']] unless request.valid_digest?
      return [400, default_response_headers, request.errors] unless request.valid_request?

      status, headers, body = client.get(request.url)
      headers = build_response_headers(headers)
      [status, headers, [body]]
    end

    private

    def build_request(env)
      @request ||= Request.new(env)
    end

    def client
      @client ||= Client.new
    end

    def build_response_headers(headers)
      headers.merge(default_response_headers)
    end
  end
end
