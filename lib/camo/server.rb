require 'rack/utils'
require 'camo/client'
require 'openssl'

module Camo
  class Server
    include Rack::Utils
    attr_reader :method, :params, :path

    def call(env)
      setup(env)

      return [404, {}, []] unless method == 'GET'

      digest, encoded_url = path[1..-1].split('/', 2).map { |part| String(part) }
      destination_url = String(encoded_url ? decode_hex(encoded_url) : params['url'])

      return [401, {}, ['Invalid digest']] unless valid_digest?(digest, destination_url)
      return [400, {}, ['Empty URL']] if destination_url.empty?

      status, headers, body = client.get(destination_url)
      headers = transform_headers(headers)
      [status, headers, [body]]
    end

    private

    def setup(env)
      @method = env['REQUEST_METHOD']
      @params = parse_query(env['QUERY_STRING'])
      @path = env['PATH_INFO']
    end

    def client
      @client ||= Client.new
    end

    def decode_hex(str)
      [str].pack('H*')
    end

    def valid_digest?(digest, url)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['CAMORB_KEY'], url) == digest
    end

    def transform_headers(headers)
      headers.reject { |key,_| %w(transfer-encoding).include? key }
    end
  end
end
