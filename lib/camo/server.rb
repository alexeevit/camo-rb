require 'rack/utils'
require 'camo/client'
require 'openssl'

module Camo
  class Server
    include Rack::Utils

    def call(env)
      return [400, {}, []] unless env['REQUEST_METHOD'] == 'GET'
      @query_string = env['QUERY_STRING']

      digest, encoded_url = env['PATH_INFO'][1..-1].split('/', 2)
      @format = encoded_url ? :path : :query

      destination_url =
        if query_format?
          params['url']
        else
          decode_hex(encoded_url)
        end
      return [400, {}, []] unless destination_url
      return [401, {}, ['Invalid digest']] unless valid_digest?(digest, destination_url)

      response = client.get(destination_url)
      headers = response[1]
      headers.delete 'transfer-encoding'

      [response[0], headers, [response[2]]]
    end

    private

    def client
      @client ||= Client.new
    end

    def params
      @params ||= parse_query(@query_string)
    end

    def query_format?
      @format == :query
    end

    def decode_hex(str)
      [str].pack('H*')
    end

    def valid_digest?(digest, url)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['CAMORB_KEY'], url) == digest
    end
  end
end
