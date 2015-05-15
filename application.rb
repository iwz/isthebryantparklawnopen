require "rubygems"
require "open-uri"
require "bundler"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

LAWN_OPEN_MESSAGES = ["The lawn is open for your enjoyment."]
LAWN_CLOSED_MESSAGES = [
  "The lawn will open at 5pm for the HBO Summer Film Festival.",
  "The lawn will open at 4:30pm for your enjoyment.",
  "The lawn is resting after the HBO Bryant Park Film Festival.",
  "The lawn will open at 12:00pm for your enjoyment.",
  "The lawn is closed until 1PM on Friday for mowing.",
]

class Lawn
  def initialize
    @page = Nokogiri::HTML(open('http://www.bryantpark.org/'))
  end

  def message
    page.css("#today_in_the_park ul:nth-child(2) > li:nth-child(2)").text.strip
  end

  def open?
    LAWN_OPEN_MESSAGES.include? message
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
  content_type :json

  Lawn.new.to_json
end

get "/stylesheets/:name.css" do
  scss :"/stylesheets/#{params[:name]}"
end


