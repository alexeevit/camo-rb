require 'rack/test'
require_relative '../environment'

Dir[File.dirname(__FILE__) + '/helpers/**/*.rb'].each { |file| require file }

RSpec.configure do |c|
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include MockHelpers

  def app
    Camo::Server.new
  end
end
