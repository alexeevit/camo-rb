require "spec_helper"
require "zlib"
require "stringio"

describe Camo::Server do
  before do
    Timecop.freeze(Time.utc(1996, 9, 28))
  end

  after { Timecop.return }

  it "raises an error if the key is not defined" do
    expect { Camo::Server.new("") }.to raise_error(Camo::Errors::UndefinedKeyError)
    expect { Camo::Server.new(nil) }.to raise_error(Camo::Errors::UndefinedKeyError)
  end

  it "returns custom camo headers, security headers, and allowed headers from remote" do
    mock_server("hello_world_server", gzip: true) do |uri|
      header "Accept-Encoding", "gzip"
      get camo_url(uri)

      expect(last_response).to be_ok
      expect(last_response.headers).to match({
        # security headers
        "X-Frame-Options" => "deny",
        "X-XSS-Protection" => "1; mode=block",
        "X-Content-Type-Options" => "nosniff",
        "Content-Security-Policy" => "default-src 'none'; img-src data:; style-src 'unsafe-inline'",
        "Strict-Transport-Security" => "max-age=31536000; includeSubDomains",

        # custom camo headers
        "Camo-Host" => "unknown",

        # allowed headers from remote
        "content-type" => "image/jpeg",
        "cache-control" => "max-age=31536000",
        "etag" => "33a64df551425fcc55e4d42a148795d9f25f89d4",
        "expires" => "Wed, 21 Oct 2021 07:28:00 GMT",
        "last-modified" => "Sat, 28 Sep 1996 00:00:00 GMT",
        "content-length" => "36",
        "content-encoding" => "gzip"
      })
    end
  end

  context "when compressed and chunked" do
    it "returns joined chunks compressed" do
      mock_server("hello_world_server", gzip: true, chunked: true) do |uri|
        header "Accept-Encoding", "gzip"
        get camo_url(uri)

        expect(last_response).to be_ok
        # expect(last_response.body).to eq('helloworld')
        expect(last_response.headers).to match({
          # security headers
          "X-Frame-Options" => "deny",
          "X-XSS-Protection" => "1; mode=block",
          "X-Content-Type-Options" => "nosniff",
          "Content-Security-Policy" => "default-src 'none'; img-src data:; style-src 'unsafe-inline'",
          "Strict-Transport-Security" => "max-age=31536000; includeSubDomains",

          # custom camo headers
          "Camo-Host" => "unknown",

          # allowed headers from remote
          "content-type" => "image/jpeg",
          "cache-control" => "max-age=31536000",
          "etag" => "33a64df551425fcc55e4d42a148795d9f25f89d4",
          "expires" => "Wed, 21 Oct 2021 07:28:00 GMT",
          "last-modified" => "Sat, 28 Sep 1996 00:00:00 GMT",
          "content-encoding" => "gzip"
        })
      end
    end
  end

  context "when the method is not GET" do
    it "returns 404" do
      post "/"
      expect(last_response.status).to eq(404)
    end
  end

  context "when url is not provided" do
    it "returns 422" do
      get camo_url("")
      expect(last_response.status).to eq(422)
      expect(last_response.body).to eq("Empty URL")
    end
  end

  context "when format is url" do
    it "returns the content of the page" do
      mock_server("hello_world_server") do |uri|
        get camo_url(uri)

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("helloworld")
      end
    end

    context "when digest is not provided" do
      it "returns 401 with error message" do
        get "/?url=https://localhost:3000"

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq("Invalid digest")
      end
    end

    context "when digest is invalid" do
      it "returns 401 with error message" do
        get "/digest?url=https://localhost:3000"

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq("Invalid digest")
      end
    end
  end

  context "when format is query" do
    it "returns the content of the page" do
      mock_server("hello_world_server") do |uri|
        get camo_url(uri, format: :query)

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("helloworld")
      end
    end

    context "when digest is not provided" do
      it "returns 401" do
        get "http://example.org//#{encode_url("https://localhost:3000")}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq("Invalid digest")
      end
    end

    context "when digest is invalid" do
      it "returns 401 with error message" do
        get "/digest/#{encode_url("https://localhost:3000")}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq("Invalid digest")
      end
    end
  end

  context "when empty host" do
    it "returns 422 with error message" do
      get camo_url("invalid")
      expect(last_response.status).to eq(422)
      expect(last_response.body).to eq("Empty host")
    end
  end

  context "when the url has unsupported protocol" do
    it "returns 422 with error message" do
      get camo_url("sftp://localhost:3000")
      expect(last_response.status).to eq(422)
      expect(last_response.body).to eq("Unsupported protocol: 'sftp'")
    end
  end

  context "when recursive request" do
    it "returns 422 with error message" do
      header "VIA", "CamoRB Asset Proxy #{Camo::Version::GEM}"
      get camo_url("http://localhost:3000")
      expect(last_response.status).to eq(422)
      expect(last_response.body).to eq("Recursive request")
    end
  end

  context "when redirect with no location" do
    it "returns 422 with error message" do
      mock_server("redirects_server") do |uri|
        get camo_url("#{uri}/empty_redirect")
        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Redirect with no location")
      end
    end
  end

  context "when too many redirects" do
    it "returns 422 with error message" do
      mock_server("redirects_server") do |uri|
        get camo_url("#{uri}/endless_redirect")
        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Too many redirects")
      end
    end
  end

  context "when timeout" do
    before { stub_const "Camo::Client::SOCKET_TIMEOUT", 1 }

    it "returns 422 with error message" do
      mock_server("timeout_server") do |uri|
        get camo_url(uri)
        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Request timeout")
      end
    end
  end

  context "when content-length is exceeded" do
    before { stub_const "Camo::Client::CONTENT_LENGTH_LIMIT", 10 }

    it "returns 422 with error message" do
      mock_server("eleven_bytes_server") do |uri|
        get camo_url(uri)
        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Max Content-Length is exceeded")
      end
    end
  end

  context "when unsupported mime-type" do
    it "returns 422 with error message" do
      mock_server("json_server") do |uri|
        get camo_url(uri)
        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Unsupported Content-Type: 'application/json'")
      end
    end
  end

  context "when response does not have content-type" do
    it "returns 422 with error message" do
      mock_server("empty_server") do |uri|
        get camo_url(uri)
        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Empty Content-Type")
      end
    end
  end
end
