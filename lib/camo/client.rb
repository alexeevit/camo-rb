require 'faraday'

module Camo
  class Client
    include Rack::Utils
    include HeadersUtils
    include MimeTypeUtils

    ALLOWED_TRANSFERRED_HEADERS = HeaderHash[%w(Host Accept Accept-Encoding)]
    KEEP_ALIVE = ['1', 'true', true].include?(ENV.fetch('CAMORB_KEEP_ALIVE', false))
    MAX_REDIRECTS = ENV.fetch('CAMORB_MAX_REDIRECTS', 4)
    SOCKET_TIMEOUT = ENV.fetch('CAMORB_SOCKET_TIMEOUT', 10)
    CONTENT_LENGTH_LIMIT = ENV.fetch('CAMORB_LENGTH_LIMIT', 5242880).to_i

    def get(url, transferred_headers = {}, remaining_redirects = MAX_REDIRECTS)
      url = URI.parse(url)
      headers = build_request_headers(transferred_headers, url: url)
      response = get_request(url, headers, timeout: SOCKET_TIMEOUT)

      case response.status
      when redirect?
        redirect(response, headers, remaining_redirects)
      when not_modified?
        [response.status, response.headers]
      else
        validate_response!(response)
        [response.status, response.headers, response.body]
      end
    end

    private

    def validate_response!(response)
      raise Errors::ContentLengthExceededError if response.headers['content-length'].to_i > CONTENT_LENGTH_LIMIT
      raise Errors::UnsupportedContentTypeError unless SUPPORTED_CONTENT_TYPES.include?(response.headers['content-type'].to_s)
    end

    def get_request(url, headers, options = {})
      Faraday.get(url, {}, headers) do |req|
        options.each do |key, value|
          req.options.public_send("#{key}=", value)
        end
      end
    rescue Faraday::TimeoutError
      raise Errors::TimeoutError
    end

    def redirect(response, headers, remaining_redirects)
      raise Errors::TooManyRedirectsError if remaining_redirects < 0
      new_url = String(response.headers['location'])
      raise Errors::RedirectWithoutLocationError if new_url.empty?

      get(new_url, headers, remaining_redirects - 1)
    end

    def not_modified?
      ->(code) { code === 304 }
    end

    def redirect?
      ->(code) { [301, 302, 303, 307, 308].include? code }
    end

    def build_request_headers(headers, url:)
      headers = headers.each_with_object({}) do |header, headers|
        key = header[0].gsub('_', '-')
        headers[key] = header[1]
      end

      headers = headers
        .select { |k,_| ALLOWED_TRANSFERRED_HEADERS.include?(k) }
        .merge(default_request_headers)

      if String(headers['Host']).empty?
        headers['Host'] = String(url.host)
        headers['Host'] += ":#{url.port}" unless [80, 443].include?(url.port)
      end

      headers['Connection'] = KEEP_ALIVE ? 'keep-alive' : 'close'

      HeaderHash[headers]
    end
  end
end
