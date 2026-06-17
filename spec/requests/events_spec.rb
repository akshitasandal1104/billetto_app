require 'rails_helper'

RSpec.describe "Events", type: :request do
  describe "GET /events" do
    context "when not authenticated" do
      it "renders the events index page" do
        get events_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated" do
      before { sign_in_as_clerk_user }

      it "renders the events index page" do
        get events_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /events/:id/vote" do
    let(:event) { Event.create!(title: "Test Event", date: Date.today) }

    context "when not authenticated" do
      before { sign_out_clerk_user }

      it "redirects away from the vote action" do
        post vote_event_path(event, vote_type: "upvote")
        expect(response).to have_http_status(:redirect)
      end

      it "does not allow voting" do
        expect {
          post vote_event_path(event, vote_type: "upvote")
        }.not_to change { event.reload.event_vote_count&.upvotes.to_i }
      end
    end

    context "when authenticated" do
      before { sign_in_as_clerk_user(user_id: "user_test_voter") }

      it "records the vote and redirects" do
        post vote_event_path(event, vote_type: "upvote")
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include("Vote recorded!")
      end

      it "accepts a downvote" do
        post vote_event_path(event, vote_type: "downvote")
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include("Vote recorded!")
      end
    end
  end
end
