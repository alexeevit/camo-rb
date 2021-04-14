require 'faraday'

module Camo
  class Client
    include Rack::Utils
    include HeadersUtils

    ALLOWED_TRANSFERRED_HEADERS = HeaderHash[%w(Host Accept Accept-Encoding)]

    def get(url, transferred_headers = {})
      url = URI.parse(url)
      headers = build_request_headers(transferred_headers, url: url)

      response = Faraday.get(url, {}, headers)
      [response.status, response.headers, response.body]
    end

    private

    def build_request_headers(headers, url:)
      headers = headers.each_with_object({}) do |header, headers|
        key = header[0].gsub('_', '-')
        headers[key] = header[1]
      end

      headers = headers
        .select { |k,_| ALLOWED_TRANSFERRED_HEADERS.include?(k) }
        .merge(default_request_headers)

      headers['Host'] = url.host if String(headers['Host']).empty?
      HeaderHash[headers]
    end
  end
end
