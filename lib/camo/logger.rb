module Camo
  class Logger
    attr_reader :outpipe, :errpipe

    def initialize(outpipe, errpipe)
      @outpipe = outpipe
      @errpipe = errpipe
    end

    def self.stdio
      new $stdout, $stderr
    end

    def debug(msg)
      outpipe.puts(msg)
    end

    def error(msg)
      errpipe.puts(msg)
    end
  end
end
