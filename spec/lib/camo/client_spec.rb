require 'spec_helper'

describe Camo::Client do
  subject(:client) { Camo::Client.new }

  describe '#get' do
    it 'returns the body and headers of the resource' do
      expected_body = <<~HTML.chomp
        <!doctype html>\n<html>\n  <head></head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>
      HTML

      mock_server('hello_world_server') do |uri|
        body, headers = subject.get(uri)
        expect(body).to eq(expected_body)
        expect(headers).to be_kind_of(Hash)
        expect(headers.size).to be > 0
      end
    end
  end
end
