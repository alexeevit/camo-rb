class JsonServer
  def call
    [200, { 'Content-Type' => 'application/json' }, ['{"hello": "world"}']]
  end
end
