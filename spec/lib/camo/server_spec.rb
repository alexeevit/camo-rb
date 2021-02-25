require 'spec_helper'

describe Camo::Server do
  def camo_url(url)
    "/?url=#{url}"
  end

  before { Timecop.freeze(Time.utc(1996, 9, 28)) }
  after { Timecop.return }

  it 'returns the content of the page' do
    mock_server('hello_world_server') do |uri|
      get camo_url(uri)

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(<<~HTML.chomp)
        <!doctype html>\n<html>\n  <head></head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>
      HTML
      expect(last_response.headers).to match({
        'x-custom-header' => 'custom value',
        'connection' => 'close',
        'content-length' => '91',
        'date' => 'Sat, 28 Sep 1996 00:00:00 GMT',
        'server' => "WEBrick/1.4.2 (Ruby/2.6.6/2020-03-31)",
      })
    end
  end
end
