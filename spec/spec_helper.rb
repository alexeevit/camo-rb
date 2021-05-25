ENV["CAMORB_ENV"] = "test"

require_relative "../environment"
require "rack/test"
require "timecop"
require "pry"

Dir[File.dirname(__FILE__) + "/helpers/**/*.rb"].sort.each { |file| require file }

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include MockHelpers
  conf.include UrlHelpers
  conf.include HeadersHelpers

  def app
    Camo::Server.new
  end
end
