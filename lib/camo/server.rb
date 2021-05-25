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
      Content-Encoding
    ).map(&:downcase)]

    attr_reader :request

    def call(env)
      build_request(env)

      return [404, default_response_headers, []] unless request.method == 'GET'

      unless request.valid_digest?
        logger.error('Invalid digest')
        return [401, default_response_headers, ['Invalid digest']]
      end

      unless request.valid_request?
        logger.error(request.errors)
        return [422, default_response_headers, request.errors.join(', ')]
      end

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
    rescue Errors::ClientError => e
      logger.error(e.message)
      return [422, default_response_headers, e.message]
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
