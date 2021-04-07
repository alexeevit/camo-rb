require 'spec_helper'

describe Camo::Server do
  before do
    Timecop.freeze(Time.utc(1996, 9, 28))
    ENV['CAMORB_KEY'] = 'somekey'
  end

  after { Timecop.return }

  it 'returns default and security headers' do
    mock_server('hello_world_server') do |uri|
      get camo_url(uri)

      # security headers
      expect(last_response.headers).to include({
        'X-Frame-Options' => "deny",
        'X-XSS-Protection' => "1; mode=block",
        'X-Content-Type-Options' => "nosniff",
        'Content-Security-Policy' => "default-src 'none'; img-src data:; style-src 'unsafe-inline'",
        'Strict-Transport-Security' => "max-age=31536000; includeSubDomains",
      })

      # default headers
      expect(last_response.headers).to include({
        'Camo-Host' => 'unknown',
        'connection' => 'close',
        'content-length' => '91',
        'date' => 'Sat, 28 Sep 1996 00:00:00 GMT',
        'server' => "WEBrick/1.4.2 (Ruby/2.6.6/2020-03-31)",
      })
    end
  end

  context 'when the method is not GET' do
    it 'returns 404' do
      post '/'
      expect(last_response.status).to eq(404)
    end
  end

  context 'when url is not provided' do
    it 'returns 400' do
      get camo_url('')
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('Empty URL')
    end
  end

  context 'when format is url' do
    it 'returns the content of the page' do
      mock_server('hello_world_server') do |uri|
        get camo_url(uri)

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(<<~HTML.chomp)
          <!doctype html>\n<html>\n  <head></head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>
        HTML
      end
    end

    context 'when digest is not provided' do
      it 'returns 401 with error message' do
        get '/?url=https://localhost:3000'

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq('Invalid digest')
      end
    end

    context 'when digest is invalid' do
      it 'returns 401 with error message' do
        get '/digest?url=https://localhost:3000'

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq('Invalid digest')
      end
    end
  end

  context 'when format is query' do
    it 'returns the content of the page' do
      mock_server('hello_world_server') do |uri|
        get camo_url(uri, format: :query)

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(<<~HTML.chomp)
          <!doctype html>\n<html>\n  <head></head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>
        HTML
      end
    end

    context 'when digest is not provided' do
      it 'returns 401' do
        get "http://example.org//#{encode_url('https://localhost:3000')}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq('Invalid digest')
      end
    end

    context 'when digest is invalid' do
      it 'returns 401 with error message' do
        get "/digest/#{encode_url('https://localhost:3000')}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq('Invalid digest')
      end
    end
  end
end
