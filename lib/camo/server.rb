require 'camo/client'

module Camo
  class Server
    def call(env)
      [200, {}, ['Hello World']]
    end
  end
end
