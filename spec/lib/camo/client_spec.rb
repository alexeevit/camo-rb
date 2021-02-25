require 'spec_helper'

describe Camo::Client do
  subject(:client) { Camo::Client.new }

  describe '#get' do
    before { Timecop.freeze(Time.utc(1996, 9, 28)) }
    after { Timecop.return }

    it 'returns the body and headers of the resource' do
      mock_server('hello_world_server') do |uri|
        status, headers, body = subject.get(uri)
        expect(body).to eq(<<~HTML.chomp)
          <!doctype html>\n<html>\n  <head></head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>
        HTML

        expect(headers).to match({
          'x-custom-header' => 'custom value',
          'connection' => 'close',
          'content-length' => '91',
          'date' => 'Sat, 28 Sep 1996 00:00:00 GMT',
          'server' => "WEBrick/1.4.2 (Ruby/2.6.6/2020-03-31)",
        })
      end
    end
  end
end
