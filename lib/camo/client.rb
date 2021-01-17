require 'faraday'

module Camo
  class Client
    def get(url)
      response = Faraday.get(url)
      [response.body, response.headers]
    end
  end
end
