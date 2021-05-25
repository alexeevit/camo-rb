class TimeoutServer
  def call(env)
    sleep 2
    [200, {}, ["Hello"]]
  end
end
