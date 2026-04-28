class Event < ApplicationRecord
  has_one :event_vote_count

  validates :title, presence: true
  validates :date, presence: true
end
