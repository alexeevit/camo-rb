require 'spec_helper'

describe Camo::Client do
  subject(:client) { Camo::Client.new }

  describe '#get' do
    before { Timecop.freeze(Time.utc(1996, 9, 28)) }
    after { Timecop.return }

    it 'returns the body and headers of the resource' do
      mock_server('hello_world_server') do |uri|
        status, headers, body = client.get(uri)
        expect(body).to eq(<<~HTML.chomp)
          <!doctype html>\n<html>\n  <head></head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>
        HTML

        expect(headers).to match({
          'connection' => 'close',
          'content-length' => '92',
          'date' => 'Sat, 28 Sep 1996 00:00:00 GMT',
          'server' => 'WEBrick/1.4.2 (Ruby/2.6.6/2020-03-31)',
          'vary' => 'Accept-Encoding',
          'cache-control' => 'max-age=31536000',
          'content-type' => 'image/*',
          'etag' => '33a64df551425fcc55e4d42a148795d9f25f89d4',
          'expires' => 'Wed, 21 Oct 2021 07:28:00 GMT',
          'last-modified' => 'Sat, 28 Sep 1996 00:00:00 GMT',
          'transfer-encoding' => 'gzip',
        })
      end
    end
  end

  describe '#build_request_headers' do
    let(:url) { URI.parse('https://google.com') }
    let(:allowed_headers) do
      {
        'Accept' => 'image/*',
        'Accept-Encoding' => '*',
      }
    end

    it 'filters transferred headers' do
      built_headers = client.send(:build_request_headers, allowed_headers.merge('X-Not-Allowed-Header' => 'value'), url: url)

      expect(built_headers).to include(allowed_headers)
      expect(built_headers).not_to include('X-Not-Allowed-Header' => 'value')
    end

    it 'adds host if it does not present' do
      built_headers = client.send(:build_request_headers, allowed_headers, url: url)
      expect(built_headers).to include('Host' => 'google.com')
    end

    it 'does not change host if it presents' do
      built_headers = client.send(:build_request_headers, { 'Host' => 'yandex.ru' }, url: url)
      expect(built_headers).to include('Host' => 'yandex.ru')
    end
  end
end
