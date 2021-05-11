require 'spec_helper'

describe Camo::Request do
  before { ENV['CAMORB_KEY'] = 'somekey' }
  subject(:request) { Camo::Request.new(env) }

  let(:env) do
    {
      'REQUEST_METHOD' => 'GET',
      'QUERY_STRING' => query,
      'PATH_INFO' => path,
      'rack.url_scheme' => 'http',
    }.merge(headers_to_env(headers))
  end

  let(:query) { '' }
  let(:path) { camo_url(url) }
  let(:headers) { { 'Host' => 'camorb', 'Accept-Encoding' => 'gzip' } }
  let(:url) { 'https://google.com' }

  describe '#initialize' do
    let(:url) { 'https://google.com' }
    let(:url_digest) { digest(url) }

    context 'when path format' do
      let(:query) { '' }
      let(:path) { "/#{url_digest}/#{encode_url(url)}" }

      it 'fills path, url and digest' do
        expect(request.path).to eq(path)
        expect(request.destination_url).to eq(url)
        expect(request.digest).to eq(url_digest)
        expect(request.digest_type).to eq('path')
      end
    end

    context 'when query format' do
      let(:query) { query_string(url) }
      let(:path) { "/#{url_digest}" }

      it 'fills path, url, digest, params' do
        expect(request.path).to eq(path)
        expect(request.params).to eq('url' => url)
        expect(request.destination_url).to eq(url)
        expect(request.digest).to eq(url_digest)
        expect(request.digest_type).to eq('query')
      end
    end

    it 'fills method and headers' do
      expect(request.method).to eq('GET')
      expect(request.headers).to eq('HOST' => 'camorb', 'ACCEPT_ENCODING' => 'gzip')
    end
  end

  describe '#request_url' do
    let(:url) { 'https://google.com' }
    let(:url_digest) { digest(url) }

    context 'when path format' do
      let(:query) { '' }
      let(:encoded_url) { encode_url(url) }
      let(:path) { "/#{url_digest}/#{encoded_url}" }

      it 'compiles the url' do
        expect(request.url).to eq("http://camorb/#{url_digest}/#{encoded_url}")
      end
    end

    context 'when query format' do
      let(:query) { query_string(url) }
      let(:path) { "/#{url_digest}" }

      it 'compiles the url' do
        expect(request.url).to eq("http://camorb/#{url_digest}?#{query}")
      end
    end
  end

  describe '#valid_request?' do
    context 'when request is valid' do
      it { expect(request.valid_request?).to be_truthy }
    end

    context 'when request is invalid' do
      let(:url) { '' }
      it { expect(request.valid_request?).to be_falsey }
    end
  end

  describe '#validate_request' do
    context 'when url is empty in path format' do
      let(:query) { '' }
      let(:path) { "/#{digest('')}" }

      it 'adds an error' do
        expect { request.send(:validate_request) }
          .to change { request.errors }.to(['Empty URL'])
      end
    end

    context 'when url is empty in query format' do
      let(:query) { 'url=' }
      let(:path) { "/#{digest('')}" }

      it 'adds an error' do
        expect { request.send(:validate_request) }
          .to change { request.errors }.to(['Empty URL'])
      end
    end

    context 'when VIA header is from Camo' do
      let(:headers) { { 'via' => Camo::HeadersUtils.user_agent } }

      it 'adds an error' do
        expect { request.send(:validate_request) }
          .to change { request.errors }.to(['Recursive request'])
      end
    end

    context 'when the request is valid' do
      it 'keeps the errors array empty' do
        expect { request.send(:validate_request) }
          .not_to change { request.errors }.from([])
      end
    end
  end

  describe '#valid_digest?' do
    context 'when digest is valid' do
      it { expect(request.send(:valid_digest?)).to be_truthy }
    end

    context 'when digest is invalid' do
      let(:path) { "/#{digest('https://google.com')}/#{encode_url('https://yandex.ru')}" }
      it { expect(request.send(:valid_digest?)).to be_falsey }
    end
  end
end
