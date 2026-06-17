require 'rails_helper'

RSpec.describe EventVoteCount, type: :model do
  let(:event) { Event.create!(title: "Test", date: Date.today) }

  it "is invalid without an event_id" do
    record = EventVoteCount.new(event_id: nil)
    expect(record).not_to be_valid
  end

  it "defaults upvotes and downvotes to zero when nil" do
    record = EventVoteCount.create!(event_id: event.id)
    expect(record.upvotes.to_i).to eq(0)
    expect(record.downvotes.to_i).to eq(0)
  end

  describe "vote counting via event store handler" do
    let(:handler) { Events::Handlers::UpdateVoteCount.new }

    it "increments upvotes when an EventUpvoted event is handled" do
      domain_event = Events::Events::EventUpvoted.new(data: { event_id: event.id, user_id: "user_abc" })
      handler.call(domain_event)

      expect(EventVoteCount.find_by(event_id: event.id).upvotes).to eq(1)
    end

    it "increments downvotes when an EventDownvoted event is handled" do
      domain_event = Events::Events::EventDownvoted.new(data: { event_id: event.id, user_id: "user_abc" })
      handler.call(domain_event)

      expect(EventVoteCount.find_by(event_id: event.id).downvotes).to eq(1)
    end

    it "accumulates multiple votes" do
      2.times do
        handler.call(Events::Events::EventUpvoted.new(data: { event_id: event.id, user_id: "u1" }))
      end
      handler.call(Events::Events::EventDownvoted.new(data: { event_id: event.id, user_id: "u2" }))

      record = EventVoteCount.find_by(event_id: event.id)
      expect(record.upvotes).to eq(2)
      expect(record.downvotes).to eq(1)
    end
  end
end
