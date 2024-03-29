require "spec_helper"

describe Camo::Client do
  subject(:client) { Camo::Client.new }

  describe "#get" do
    before { Timecop.freeze(Time.utc(1996, 9, 28)) }
    after { Timecop.return }

    it "returns the body and headers of the resource" do
      mock_server("hello_world_server") do |uri|
        status, headers, body = client.get(uri)

        expect(status).to eq(200)
        expect(body).to eq("helloworld")
        expect(headers).to match({
          "connection" => "close",
          "content-length" => "10",
          "date" => "Sat, 28 Sep 1996 00:00:00 GMT",
          "server" => /WEBrick/,
          "cache-control" => "max-age=31536000",
          "content-type" => "image/jpeg",
          "etag" => "33a64df551425fcc55e4d42a148795d9f25f89d4",
          "expires" => "Wed, 21 Oct 2021 07:28:00 GMT",
          "last-modified" => "Sat, 28 Sep 1996 00:00:00 GMT"
        })
      end
    end

    it "follows redirects" do
      mock_server("redirects_server") do |uri|
        status, _headers, body = client.get(uri)
        expect(status).to eq(200)
        expect(body).to eq("Redirected")
      end
    end

    context "when chunked and compressed" do
      it "returns the body and headers of the resource" do
        mock_server("hello_world_server", chunked: true, gzip: true) do |uri|
          status, headers, body = client.get(uri)

          expect(status).to eq(200)
          expect(body).to eq("helloworld")
          expect(headers).to match({
            "connection" => "close",
            "date" => "Sat, 28 Sep 1996 00:00:00 GMT",
            "server" => /WEBrick/,
            "vary" => "Accept-Encoding",
            "cache-control" => "max-age=31536000",
            "content-type" => "image/jpeg",
            "etag" => "33a64df551425fcc55e4d42a148795d9f25f89d4",
            "expires" => "Wed, 21 Oct 2021 07:28:00 GMT",
            "last-modified" => "Sat, 28 Sep 1996 00:00:00 GMT",
            "transfer-encoding" => "chunked"
          })
        end
      end
    end

    context "when too many redirects" do
      it "raises an error" do
        mock_server("redirects_server") do |uri|
          expect { client.get("#{uri}/endless_redirect") }.to raise_error Camo::Errors::TooManyRedirectsError
        end
      end
    end

    context "when redirect without location" do
      it "raises an error" do
        mock_server("redirects_server") do |uri|
          expect { client.get("#{uri}/empty_redirect") }.to raise_error Camo::Errors::RedirectWithoutLocationError
        end
      end
    end

    context "when not modified" do
      it "returns empty body" do
        mock_server("redirects_server") do |uri|
          status, _headers, body = client.get("#{uri}/not_modified")
          expect(status).to eq(304)
          expect(body).to be_nil
        end
      end
    end

    context "when KEEP_ALIVE is disabled" do
      before { stub_const "Camo::Client::KEEP_ALIVE", false }

      it "sends Connection: close" do
        mock_server("hello_world_server") do |uri|
          _status, headers, _body = client.get(uri)
          expect(headers).to include("connection" => "close")
        end
      end
    end

    context "when KEEP_ALIVE is enabled" do
      before { stub_const "Camo::Client::KEEP_ALIVE", true }

      it "sends Connection: keep-alive" do
        mock_server("hello_world_server") do |uri|
          _status, headers, _body = client.get(uri)
          expect(headers).to include("connection" => "Keep-Alive")
        end
      end
    end

    context "when request exceeds the timeout" do
      before { stub_const "Camo::Client::SOCKET_TIMEOUT", 1 }

      it "raises an error" do
        mock_server("timeout_server") do |uri|
          expect { client.get(uri) }.to raise_error Camo::Errors::TimeoutError
        end
      end
    end

    context "when too big response Content-Length" do
      before { stub_const "Camo::Client::CONTENT_LENGTH_LIMIT", 10 }

      it "raises an error" do
        mock_server("eleven_bytes_server") do |uri|
          expect { client.get(uri) }.to raise_error Camo::Errors::ContentLengthExceededError
        end
      end
    end

    context "when not supported Content-Type" do
      it "raises an error" do
        mock_server("json_server") do |uri|
          expect { client.get(uri) }.to raise_error Camo::Errors::UnsupportedContentTypeError, "Unsupported Content-Type: 'application/json'"
        end
      end
    end

    context "when does not have Content-Type" do
      it "raises an error" do
        mock_server("empty_server") do |uri|
          expect { client.get(uri) }.to raise_error Camo::Errors::EmptyContentTypeError
        end
      end
    end
  end

  describe "#build_request_headers" do
    let(:url) { URI.parse("https://google.com") }
    let(:allowed_headers) do
      {
        "Accept" => "image/*",
        "Accept-Encoding" => "*"
      }
    end

    it "filters transferred headers" do
      built_headers = client.send(:build_request_headers, allowed_headers.merge("X-Not-Allowed-Header" => "value"), url: url)

      expect(built_headers).to include(allowed_headers)
      expect(built_headers).not_to include("X-Not-Allowed-Header" => "value")
    end

    it "adds host if it does not present" do
      built_headers = client.send(:build_request_headers, allowed_headers, url: url)
      expect(built_headers).to include("Host" => "google.com")
    end

    it "does not change host if it presents" do
      built_headers = client.send(:build_request_headers, {"Host" => "yandex.ru"}, url: url)
      expect(built_headers).to include("Host" => "yandex.ru")
    end
  end
end
