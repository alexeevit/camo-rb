class ElevenBytesServer
  def call(env)
    return [200, {}, ['a' * 11]]
  end
end
