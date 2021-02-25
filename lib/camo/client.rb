require 'faraday'

module Camo
  class Client
    def get(url)
      response = Faraday.get(url)
      [response.status, response.headers, response.body]
    end
  end
end
