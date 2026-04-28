class EventVoteCount < ApplicationRecord
    validates :event_id, presence: true
end
