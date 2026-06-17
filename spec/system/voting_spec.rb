require 'rails_helper'

RSpec.describe "Voting", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:event) { Event.create!(title: "Jazz Night", date: 1.week.from_now) }

  context "when not authenticated" do
    it "redirects away when attempting to vote" do
      visit events_path
      expect(page).to have_content("Jazz Night")

      # No Clerk session cookie — vote should redirect, not process
      page.driver.post vote_event_path(event, vote_type: "upvote")
      expect(page.driver.response.status).to be_in([301, 302])
    end
  end

  context "when authenticated via Clerk" do
    before do
      # Stub Clerk SDK so the backend accepts the fake session token
      claims = { "sub" => "user_browser_test_001" }
      sdk_double = instance_double(Clerk::SDK, verify_token: claims)
      allow(Clerk::SDK).to receive(:new).and_return(sdk_double)

      # Set the session cookie that ApplicationController reads
      page.driver.browser.set_cookie("__session=fake.clerk.token; path=/")
    end

    it "shows the events listing" do
      visit events_path
      expect(page).to have_content("Jazz Night")
    end

    it "records an upvote and updates the displayed count" do
      visit events_path
      expect(page).to have_content("Upvotes: 0")

      page.driver.post vote_event_path(event, vote_type: "upvote")
      visit events_path

      expect(page).to have_content("Upvotes: 1")
    end

    it "records a downvote and updates the displayed count" do
      visit events_path

      page.driver.post vote_event_path(event, vote_type: "downvote")
      visit events_path

      expect(page).to have_content("Downvotes: 1")
    end
  end
end
