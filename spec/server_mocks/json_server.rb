class JsonServer
  def call(_env)
    [200, {"Content-Type" => "application/json"}, ['{"hello": "world"}']]
  end
end
