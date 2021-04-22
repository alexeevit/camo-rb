class TimeoutServer
  def call(env)
    sleep 2
    return [200, {}, ['Hello']]
  end
end
