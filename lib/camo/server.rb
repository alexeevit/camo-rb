require 'rack/utils'
require 'openssl'

module Camo
  class Server
    include Rack::Utils
    include HeadersUtils

    ALLOWED_REMOTE_HEADERS = HeaderHash[%w(
      Content-Type
      Cache-Control
      eTag
      Expires
      Last-Modified
      Content-Length
      Transfer-Encoding
      Content-Encoding
    ).map(&:downcase)]

    attr_reader :request

    def call(env)
      build_request(env)

      return [404, default_response_headers, []] unless request.method == 'GET'
      return [401, default_response_headers, ['Invalid digest']] unless request.valid_digest?
      return [400, default_response_headers, request.errors] unless request.valid_request?

      logger.debug 'Request', {
        type: request.digest_type,
        url: request.url,
        headers: request.headers,
        destination: request.destination_url,
        digest: request.digest
      }

      status, headers, body = client.get(request.destination_url, request.headers)
      headers = build_response_headers(headers)
      logger.debug 'Response', { status: status, headers: headers, body_bytesize: body.bytesize }

      [status, headers, [body]]
    end

    private

    def logger
      @logger ||= Logger.stdio
    end

    def build_request(env)
      @request ||= Request.new(env)
    end

    def client
      @client ||= Client.new
    end

    def build_response_headers(headers)
      headers
        .select { |k,_| ALLOWED_REMOTE_HEADERS.include?(k.downcase) }
        .merge(default_response_headers)
    end
  end
end
