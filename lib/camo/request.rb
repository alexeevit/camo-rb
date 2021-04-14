require 'rack/utils'

module Camo
  class Request
    include Rack::Utils
    include HeadersUtils
    attr_reader :method, :path, :headers, :params, :url, :digest, :errors

    def initialize(env)
      @method = env['REQUEST_METHOD']
      @params = parse_query(env['QUERY_STRING'])
      @path = env['PATH_INFO']
      @headers = build_headers(env)

      @digest, encoded_url = path[1..-1].split('/', 2).map { |part| String(part) }
      @url = String(encoded_url ? decode_hex(encoded_url) : params['url'])
      @errors = []
    end

    def valid_request?
      validate_request
      Array(errors).empty?
    end

    def valid_digest?
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['CAMORB_KEY'], url) == digest
    end

    private

    def build_headers(env)
      hash = env.select { |k,_| k.start_with?('HTTP_') }
      hash = hash.each_with_object({}) do |header, headers|
        headers[header[0].sub('HTTP_', '')] = header[1]
      end

      HeaderHash[hash]
    end

    def validate_request
      @errors ||= []

      errors << 'Empty URL' if url.empty?
      errors << 'Recursive request' if headers['VIA'] == user_agent
      errors
    end

    def decode_hex(str)
      [str].pack('H*')
    end
  end
end
