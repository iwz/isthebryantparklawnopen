require "./application"
require "./bryant_park_api"

if ENV["MEMCACHIER_SERVERS"]
  client = BryantParkApi::DALLI

  use(
    Rack::Cache,
    verbose: true,
    metastore:   client,
    entitystore: client
  )
end

run Sinatra::Application
