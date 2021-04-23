module Camo
  module Errors
    class RedirectWithoutLocationError < ::StandardError; end

    class TooManyRedirectsError < ::StandardError; end

    class TimeoutError < ::StandardError; end

    class ContentLengthExceededError < ::StandardError; end
  end
end
