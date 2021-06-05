module Camo
  module HeadersUtils
    HOSTNAME = ENV.fetch("CAMORB_HOSTNAME", "unknown")
    TIMING_ALLOW_ORIGIN = ENV.fetch("CAMORB_TIMING_ALLOW_ORIGIN", nil)

    REQUEST_SECURITY_HEADERS = {
      "X-Frame-Options" => "deny",
      "X-XSS-Protection" => "1; mode=block",
      "X-Content-Type-Options" => "nosniff",
      "Content-Security-Policy" => "default-src 'none'; img-src data:; style-src 'unsafe-inline'"
    }

    RESPONSE_SECURITY_HEADERS = REQUEST_SECURITY_HEADERS.merge({
      "Strict-Transport-Security" => "max-age=31536000; includeSubDomains"
    })

    def self.user_agent
      ENV.fetch("CAMORB_HEADER_VIA", "CamoRB Asset Proxy #{Camo::Version::GEM}")
    end

    def default_response_headers
      RESPONSE_SECURITY_HEADERS.merge({
        "Camo-Host" => HOSTNAME,
        "Timing-Allow-Origin" => TIMING_ALLOW_ORIGIN
      }).compact
    end

    def default_request_headers
      REQUEST_SECURITY_HEADERS.merge({
        "Via" => user_agent,
        "User-Agent" => user_agent
      })
    end

    def user_agent
      HeadersUtils.user_agent
    end
  end
end
