require "rubygems"
require "open-uri"
require "bundler"
require "dalli"
require 'net/http'

require "./bryant_park_api"
require "./image"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

LAWN_OPEN_MESSAGES = [
  "The Lawn is open"
]

class Lawn
  def initialize
    json = BryantParkApi.json
    @page = json["page"]
  end

  def message
    "#{lawn_status} #{page["lawnClosedExplanation"].strip}"
  end

  def lawn_status
    page["lawnStatus"]
  end

  def open?
    LAWN_OPEN_MESSAGES.include? lawn_status
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

get "/lawn-webcam.jpg" do
  content_type 'image/jpeg', charset: "utf-8"

  uri = URI('http://webcam.bryantpark.org/axis-cgi/jpg/image.cgi?resolution=1920x1080')

  Net::HTTP.get(uri)
end

get "/lawn-webcam-thumb.jpg" do
  content_type 'image/jpeg', charset: "utf-8"

  uri = URI('http://webcam.bryantpark.org/axis-cgi/jpg/image.cgi?resolution=640x480')

  Net::HTTP.get(uri)
end

get "/count" do
  uri = URI('http://webcam.bryantpark.org/axis-cgi/jpg/image.cgi?resolution=1920x1080')
  data = Net::HTTP.get(uri)
  i = Image.new(data: data)

  lawn = Lawn.new
  @lawn_message = lawn.message

  if i.count > 0
    @open = "Yes (#{i.count})"
  else
    @open = "No (#{i.count})"
  end

  slim :index
end

get "/count-from-file" do
  i = Image.new(source_image_path: "/Users/iwz/workspace/isthebryantparklawnopen/tmp/lawn-2017-06-29-16-11.jpg")

  lawn = Lawn.new
  @lawn_message = lawn.message

  if i.count > 0
    @open = "Yes (#{i.count})"
  else
    @open = "No (#{i.count})"
  end

  slim :index
end
