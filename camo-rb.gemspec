Gem::Specification.new do |s|
  s.name        = "camo-rb"
  s.version     = "0.0.1"
  s.summary     = "An SSL/TLS image proxy that uses HMAC signed URLs."
  s.description = "A camo server is a special type of image proxy that proxies non-secure images over SSL/TLS, in order to prevent mixed content warnings on secure pages. The server works in conjunction with back-end code that rewrites image URLs and signs them with an HMAC."
  s.authors     = ["Vyacheslav Alexeev"]
  s.email       = "alexeev.corp@gmail.com"
  s.files       = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.homepage    = "https://github.com/alexeevit/camo-rb"
  s.license     = "MIT"
end
