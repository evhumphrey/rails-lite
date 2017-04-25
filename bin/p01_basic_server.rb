require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  # path = env["REQUEST_PATH"]

  res = Rack::Response.new
  res['Content-type'] = 'text/html; charset=utf-8'
  res.write(req.path)
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
