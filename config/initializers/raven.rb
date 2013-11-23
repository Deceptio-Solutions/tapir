require 'raven'

Raven.configure do |config|
  config.dsn = 'https://username:password@app.getsentry.com/16081'
end
