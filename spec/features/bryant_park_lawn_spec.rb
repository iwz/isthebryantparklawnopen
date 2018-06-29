require "spec_helper"

RSpec.describe "Bryant Park Lawn status", type: :feature do
  def stub_bryant_park_api(lawn_status)
    allow(BryantParkApi).to receive(:json).and_return(
      {
        "page": {
          "lawnStatus": lawn_status
        }
      }
    )
  end

  it "when the lawn is closed" do
    stub_bryant_park_api("The Lawn is closed")

    visit "/"

    expect(page).to have_text "No"
  end

  it "when the lawn is open" do
    stub_bryant_park_api("The Lawn is open")

    visit "/"

    expect(page).to have_text "Yes"
  end
end
