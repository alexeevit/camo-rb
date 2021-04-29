class ElevenBytesServer
  def call(env)
    return [200, { 'Content-Type' => 'image/jpeg' }, ['a' * 11]]
  end
end
