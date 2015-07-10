require './application'

if ENV["MEMCACHIER_SERVERS"]
  client = Dalli::Client.new(
    (ENV["MEMCACHIER_SERVERS"] || "").split(","),
    username: ENV["MEMCACHIER_USERNAME"],
    password: ENV["MEMCACHIER_PASSWORD"],
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2,
    value_max_bytes: 10485760
  )

  use(
    Rack::Cache,
    verbose: true,
    metastore:   client,
    entitystore: client
  )
end

run Sinatra::Application
