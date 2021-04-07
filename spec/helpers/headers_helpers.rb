module HeadersHelpers
  def headers_to_env(headers)
    headers.each_with_object({}) do |header, headers|
      new_key = 'HTTP_' + String(header[0]).gsub('-', '_').upcase
      headers[new_key] = header[1]
    end
  end
end
