class EmptyServer
  def call(_env)
    [200, {}, []]
  end
end
