require "dalli"
require "json"
require "open-uri"

class BryantParkApi
  BRYANT_PARK_API = "http://bryantpark.org/json/pages-home"
  CACHE_KEY = "bryant_park_api"
  DALLI = Dalli::Client.new(
    (ENV["MEMCACHIER_SERVERS"] || "localhost:11211").split(","),
    username: ENV["MEMCACHIER_USERNAME"] || "",
    password: ENV["MEMCACHIER_PASSWORD"] || "",
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2,
    value_max_bytes: 10485760
  )

  def self.json
    DALLI.get(CACHE_KEY) || load
  end

  def self.load
    json = JSON.load(open(BRYANT_PARK_API))
    DALLI.set(CACHE_KEY, json, ttl=1800) # expire after 30 minutes. heroku scheduler overwrites every 10 minutes anyway
    json
  end

  def self.clear
    DALLI.flush
  end
end

