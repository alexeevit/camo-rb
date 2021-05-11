module Camo
  class Logger
    attr_reader :outpipe, :errpipe

    LOG_LEVELS = ['debug', 'error', 'fatal'].freeze
    LOG_LEVEL = (LOG_LEVELS.find { |level| level == ENV['CAMORB_LOG_LEVEL'] } || 'fatal').freeze

    def initialize(outpipe, errpipe)
      @outpipe = outpipe
      @errpipe = errpipe
    end

    def self.stdio
      new $stdout, $stderr
    end

    def debug(msg, params = {})
      outpipe.puts(compile_output(msg, params)) if debug?
    end

    def error(msg, params = {})
      errpipe.puts(compile_output(msg, params)) if error?
    end

    private

    def debug?
      LOG_LEVELS.find_index(LOG_LEVEL) <= LOG_LEVELS.find_index('debug')
    end

    def error?
      LOG_LEVELS.find_index(LOG_LEVEL) <= LOG_LEVELS.find_index('error')
    end

    def compile_output(msg, params)
      output = msg

      if params.any?
        output = "#{output} | #{convert_params_to_string(params)}"
      end

      output
    end

    def convert_params_to_string(params)
      elements = []

      params.each do |key, value|
        compiled_value =
          if value.is_a?(Hash)
            convert_params_to_string(value)
          else
            "\"#{value}\""
          end

        elements << "#{key}: #{compiled_value}"
      end

      "{ #{elements.join(', ')} }"
    end
  end
end
