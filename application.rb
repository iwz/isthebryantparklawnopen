require "sinatra"
require "slim"
require 'nokogiri'
require 'open-uri'
require 'pry'

LAWN_OPEN_MESSAGES = ["The lawn is open for your enjoyment."]
LAWN_CLOSED_MESSAGES = [
  "The lawn will open at 5pm for the HBO Summer Film Festival.",
  "The lawn will open at 4:30pm for your enjoyment.",
  "The lawn is resting after the HBO Bryant Park Film Festival.",
  "The lawn will open at 12:00pm for your enjoyment.",
  "The lawn is closed until 1PM on Friday for mowing.",
]

get "/" do
  page = Nokogiri::HTML(open('http://www.bryantpark.org/'))

  @lawn_message = page.css("#today_in_the_park ul:nth-child(2) > li:nth-child(2)").text.strip

  if LAWN_OPEN_MESSAGES.include? @lawn_message
    @open = "Yes"
  else
    @open = "No"
  end

  slim :index
end
