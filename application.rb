require "rubygems"
require "open-uri"
require "bundler"
require "dalli"
require "./bryant_park_api"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym


class Lawn
  def initialize
    json = BryantParkApi.json
    @page = json["page"]
  end

  def message
    page["lawnClosedExplanation"].strip
  end

  def open?
    page["isParkOpen"]
  end

  def to_json
    {
      open: open?,
      message: message,
      timestamp: Time.now
    }.to_json
  end

  private

  attr_reader :page
end

get "/" do
  cache_control :public, max_age: 300  # 5 mins.

  lawn = Lawn.new
  @lawn_message = lawn.message

  if lawn.open?
    @open = "Yes"
  else
    @open = "No"
  end

  slim :index
end

get "/api" do
  cache_control :public, max_age: 300  # 5 mins.

  content_type :json

  Lawn.new.to_json
end

get "/stylesheets/:name.css" do
  cache_control :public, max_age: 1800  # 30 mins.

  scss :"/stylesheets/#{params[:name]}"
end

get "/flush" do
  BryantParkApi.clear

  "ok"
end

