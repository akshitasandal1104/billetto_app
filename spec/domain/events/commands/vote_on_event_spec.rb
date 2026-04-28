RSpec.describe Events::Commands::VoteOnEvent do
  let(:event_store) { Rails.configuration.event_store }

  it "publishes upvote event" do
    command = described_class.new(
      event_id: 1,
      user_id: 1,
      vote_type: "upvote"
    )

    expect {
      command.call
    }.to change { event_store.read.count }.by(1)
  end
end