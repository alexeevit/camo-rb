require 'faraday'

module Camo
  class Client
    include Rack::Utils
    include HeadersUtils

    ALLOWED_TRANSFERRED_HEADERS = HeaderHash[%w(Host Accept Accept-Encoding)]
    MAX_REDIRECTS = ENV.fetch('CAMORB_MAX_REDIRECTS', 4)

    def get(url, transferred_headers = {}, remaining_redirects = MAX_REDIRECTS)
      url = URI.parse(url)
      headers = build_request_headers(transferred_headers, url: url)

      response = Faraday.get(url, {}, headers)
      case response.status
      when redirect?
        redirect(response, headers, remaining_redirects)
      when not_modified?
        [response.status, response.headers]
      else
        [response.status, response.headers, response.body]
      end
    end

    private

    def redirect(response, headers, remaining_redirects)
      raise Errors::TooManyRedirects if remaining_redirects < 0
      new_url = String(response.headers['location'])
      raise Errors::RedirectWithoutLocation if new_url.empty?

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

      HeaderHash[headers]
    end
  end
end
