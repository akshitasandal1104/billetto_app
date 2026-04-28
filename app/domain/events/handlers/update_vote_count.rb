module Events
  module Handlers
    class UpdateVoteCount
      def self.subscriptions
        {
          Events::Events::EventUpvoted => [new],
          Events::Events::EventDownvoted => [new]
        }
      end

      def call(event)
        data = event.data
        record = EventVoteCount.find_or_initialize_by(event_id: data[:event_id])

        if event.is_a?(Events::Events::EventUpvoted)
          record.upvotes ||= 0
          record.upvotes += 1
        else
          record.downvotes ||= 0
          record.downvotes += 1
        end

        record.save!
      end
    end
  end
end