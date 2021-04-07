require 'faraday'

module Camo
  class Client
    include HeadersUtils
    ALLOWED_TRANSFERRED_HEADERS = %w(Host Accept Accept-Encoding) # TODO check - _ and case sensitivity

    def get(url, transferred_headers = {})
      url = URI.parse(url)
      headers = build_request_headers(transferred_headers, url: url)

      response = Faraday.get(url, {}, headers)
      [response.status, response.headers, response.body]
    end

    private

    def build_request_headers(headers, url:)
      headers = headers
        .select { |k,_| ALLOWED_TRANSFERRED_HEADERS.include?(k) }
        .merge(default_request_headers)

      headers['Host'] = url.host if String(headers['Host']).empty?
      headers
    end
  end
end
