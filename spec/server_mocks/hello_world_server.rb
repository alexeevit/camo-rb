class HelloWorldServer
  def call(env)
    return [200, { 'X-Custom-Header' => 'custom value' }, [<<~HTML.chomp]] if env['REQUEST_METHOD'] == 'GET'
      <!doctype html>
      <html>
        <head></head>
        <body>
          <h1>Hello World!</h1>
        </body>
      </html>
    HTML
    [404, {}, []]
  end
end
