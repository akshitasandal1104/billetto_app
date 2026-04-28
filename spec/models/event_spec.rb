RSpec.describe Event, type: :model do
  it "is invalid without title" do
    event = Event.new(title: nil)
    expect(event).not_to be_valid
  end

  it "is invalid without date" do
    event = Event.new(date: nil)
    expect(event).not_to be_valid
  end
end