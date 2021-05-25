class ElevenBytesServer
  def call(env)
    [200, {"Content-Type" => "image/jpeg"}, ["a" * 11]]
  end
end
