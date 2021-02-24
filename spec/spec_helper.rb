ENV['CAMORB_ENV'] = 'test'

require_relative '../environment'
require 'rack/test'
require 'timecop'

Dir[File.dirname(__FILE__) + '/helpers/**/*.rb'].each { |file| require file }

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include MockHelpers

  def app
    Camo::Server.new
  end
end
