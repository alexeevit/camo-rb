class RedirectsServer
  def call(env)
    return [304, {}, ['Not modified body']] if env['PATH_INFO'] == '/not_modified'
    return [301, { 'Location' => '/endless_redirect' }, []] if env['PATH_INFO'] == '/endless_redirect'
    return [301, { }, []] if env['PATH_INFO'] == '/empty_redirect'
    return [200, {}, ['Redirected']] if env['PATH_INFO'] == '/redirect'
    [301, { 'Location' => '/redirect' }, []]
  end
end
