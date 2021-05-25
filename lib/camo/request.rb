require "rack/utils"
require "addressable/uri"

module Camo
  class Request
    include Rack::Utils
    include HeadersUtils

    SUPPORTED_PROTOCOLS = %w[http https]

    attr_reader :method, :protocol, :host, :path, :headers, :query_string, :params, :destination_url, :digest, :digest_type, :errors

    def initialize(env)
      @method = env["REQUEST_METHOD"]
      @query_string = env["QUERY_STRING"]
      @params = parse_query(@query_string)
      @protocol = env["rack.url_scheme"] || "http"
      @host = env["HTTP_HOST"]
      @path = env["PATH_INFO"]
      @headers = build_headers(env)

      @digest, encoded_url = path[1..].split("/", 2).map { |part| String(part) }

      if encoded_url
        @digest_type = "path"
        @destination_url = Addressable::URI.parse(String(decode_hex(encoded_url)))
      else
        @digest_type = "query"
        @destination_url = Addressable::URI.parse(String(params["url"]))
      end

      @errors = []
    end

    def url
      "#{protocol}://#{host}#{path}#{query_string.empty? ? nil : "?#{query_string}"}"
    end

    def valid_request?
      validate_request
      Array(errors).empty?
    end

    def valid_digest?
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), ENV["CAMORB_KEY"], destination_url) == digest
    end

    private

    def build_headers(env)
      hash = env.select { |k, _| k.start_with?("HTTP_") }
      hash = hash.each_with_object({}) do |header, headers|
        headers[header[0].sub("HTTP_", "")] = header[1]
      end

      HeaderHash[hash]
    end

    def validate_request
      @errors ||= []

      errors << "Empty URL" if destination_url.empty?
      errors << "Empty host" if !destination_url.empty? && String(destination_url.host).empty?

      if destination_url.scheme && !SUPPORTED_PROTOCOLS.include?(destination_url.scheme)
        errors << "Unsupported protocol: '#{destination_url.scheme}'"
      end

      errors << "Recursive request" if headers["VIA"] == user_agent
      errors
    end

    def decode_hex(str)
      [str].pack("H*")
    end
  end
end
