require 'rack/test'
require_relative '../environment'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods

  def app
    Camo::Server.new
  end
end
