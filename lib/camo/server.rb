require 'rack/utils'
require 'camo/client'

module Camo
  class Server
    include Rack::Utils

    def call(env)
      return [400, {}, []] unless env['REQUEST_METHOD'] == 'GET' && env['PATH_INFO'] == '/'
      @query_string = env['QUERY_STRING']
      return [400, {}, []] unless params.key?('url')

      response = client.get(params.fetch('url'))

      headers = response[1]
      headers.delete 'transfer-encoding'

      [response[0], headers, [response[2]]]
    end

    def client
      @client ||= Client.new
    end

    def params
      @params ||= parse_query(@query_string)
    end

    def query_parser
      @query_parser ||= Rack::QueryParser.new(Hash)
    end
  end
end
