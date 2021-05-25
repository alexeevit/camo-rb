class HelloWorldServer
  def call(env)
    headers = {
      'Content-Type' => 'image/jpeg',
      'Cache-Control' => 'max-age=31536000',
      'Etag' => '33a64df551425fcc55e4d42a148795d9f25f89d4',
      'Expires' => 'Wed, 21 Oct 2021 07:28:00 GMT',
      'Last-Modified' => 'Sat, 28 Sep 1996 00:00:00 GMT',
    }

    return [200, headers, ['helloworld']]
  end
end
