require 'openssl'

module UrlHelpers
  def camo_url(url, format: :path)
    raise ArgumentError, 'Format argument must be :path (default) or :query' unless [:path, :query].include? format

    return "/#{digest(url)}?#{query_string(url)}" if format == :query
    "/#{digest(url)}/#{encode_url(url)}"
  end

  def query_string(url)
    "url=#{url}"
  end

  def encode_url(url)
    url.bytes.map { |byte| '%02x' % byte }.join
  end

  def digest(url)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['CAMORB_KEY'], url)
  end
end
