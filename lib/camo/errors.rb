module Camo
  module Errors
    class ClientError < ::StandardError; end

    class RedirectWithoutLocationError < ClientError
      def initialize(message = 'Redirect with no location'); super; end
    end

    class TooManyRedirectsError < ClientError
      def initialize(message = 'Too many redirects'); super; end
    end

    class TimeoutError < ClientError
      def initialize(message = 'Request timeout'); super; end
    end

    class ContentLengthExceededError < ClientError
      def initialize(message = 'Max Content-Length is exceeded'); super; end
    end

    class UnsupportedContentTypeError < ClientError
      def initialize(content_type, message = "Unsupported Content-Type: '#{content_type}'"); super(message); end
    end

    class EmptyContentTypeError < ClientError
      def initialize(message = 'Empty Content-Type'); super; end
    end
  end
end
