class HelloWorldServer
  def call(env)
    headers = {
      'Content-Type' => 'image/*',
      'Cache-Control' => 'max-age=31536000',
      'Etag' => '33a64df551425fcc55e4d42a148795d9f25f89d4',
      'Expires' => 'Wed, 21 Oct 2021 07:28:00 GMT',
      'Last-Modified' => 'Sat, 28 Sep 1996 00:00:00 GMT',
      'Transfer-Encoding' => 'gzip',
    }

    return [200, headers, [<<~HTML.chomp]] if env['REQUEST_METHOD'] == 'GET'
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
