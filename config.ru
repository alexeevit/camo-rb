require_relative "environment"

begin
  run Camo::Server.new(ENV["CAMORB_KEY"])
rescue Camo::Errors::AppError => e
  abort("Error: #{e.message}")
end
