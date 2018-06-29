require "spec_helper"

RSpec.describe "Bryant Park Lawn status", :type => :feature do

  it "when the lawn is closed" do
    visit "/"

    expect(page).to have_text("No")
  end

  it "when the lawn is open" do
    visit "/"

    expect(page).to have_text("Yes")
  end
end
