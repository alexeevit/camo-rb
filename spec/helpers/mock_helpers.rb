module MockHelpers
  MOCK_RUN_TIMEOUT = 5

  def mock_server(name, host = "localhost", port = 38750, gzip: false, chunked: false)
    reader, writer = IO.pipe

    pid = fork do
      $stdout.reopen "/dev/null"
      $stderr.reopen "/dev/null"

      reader.close
      require_relative "../server_mocks/#{name}"
      server_class = Object.const_get(camelize(name.to_s.sub(/.*\./, "".freeze)))

      builder = Rack::Builder.new do
        use Rack::Chunked if chunked
        use Rack::Deflater if gzip
        run server_class.new
      end

      Rack::Handler::WEBrick.run(builder, Host: host, Port: port) do |server|
        writer.puts(1) # signal that the server is up
      end
    end

    writer.close

    begin
      reader.read_nonblock(1) # start only when the server is up

      yield "http://#{host}:#{port}"
    rescue IO::WaitReadable
      IO.select([reader])
      retry
    ensure
      Process.kill(:KILL, pid)
    end
  end

  def camelize(string)
    string = string.sub(/^[a-z\d]*/) { |match| match.capitalize }
    string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub("/", "::")
  end
end
