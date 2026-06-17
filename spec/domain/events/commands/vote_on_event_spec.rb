require 'rails_helper'

RSpec.describe Events::Commands::VoteOnEvent do
  let(:event_store) { Rails.configuration.event_store }
  let(:event_id) { 42 }
  let(:user_id) { "user_clerk_abc123" }

  describe "upvote" do
    let(:command) { described_class.new(event_id: event_id, user_id: user_id, vote_type: "upvote") }

    it "publishes one event to the store" do
      expect { command.call }.to change { event_store.read.count }.by(1)
    end

    it "publishes an EventUpvoted event" do
      command.call
      last_event = event_store.read.last
      expect(last_event).to be_a(Events::Events::EventUpvoted)
    end

    it "stores the user_id in the event payload for traceability" do
      command.call
      last_event = event_store.read.last
      expect(last_event.data[:user_id]).to eq(user_id)
    end

    it "stores the event_id in the event payload" do
      command.call
      last_event = event_store.read.last
      expect(last_event.data[:event_id]).to eq(event_id)
    end
  end

  describe "downvote" do
    let(:command) { described_class.new(event_id: event_id, user_id: user_id, vote_type: "downvote") }

    it "publishes one event to the store" do
      expect { command.call }.to change { event_store.read.count }.by(1)
    end

    it "publishes an EventDownvoted event" do
      command.call
      last_event = event_store.read.last
      expect(last_event).to be_a(Events::Events::EventDownvoted)
    end

    it "stores the user_id in the event payload for traceability" do
      command.call
      last_event = event_store.read.last
      expect(last_event.data[:user_id]).to eq(user_id)
    end
  end

  describe "invalid vote type" do
    it "raises an error" do
      command = described_class.new(event_id: event_id, user_id: user_id, vote_type: "meh")
      expect { command.call }.to raise_error(RuntimeError, /Invalid vote type/)
    end
  end
end
