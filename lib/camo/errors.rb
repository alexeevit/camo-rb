module Camo
  module Errors
    class RedirectWithoutLocationError < ::StandardError; end

    class TooManyRedirectsError < ::StandardError; end

    class TimeoutError < ::StandardError; end
  end
end
