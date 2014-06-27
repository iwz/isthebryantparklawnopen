require "sinatra"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "slim"

include Capybara::DSL

Capybara.app = Sinatra::Application
Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://bryantpark.org"

LAWN_OPEN_MESSAGES = ["The lawn is open for your enjoyment."]

get "/" do
  visit "/"

  within "#today_in_the_park" do
    lawn_message = find("ul:nth-child(2) > li:nth-child(2)").text

    if LAWN_OPEN_MESSAGES.include? lawn_message
      @open = "Yes"
    else
      @open = "No"
    end
  end

  slim :index
end
