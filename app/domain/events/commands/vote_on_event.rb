module Events
  module Commands
    class VoteOnEvent
      def initialize(event_id:, user_id:, vote_type:)
        @event_id = event_id
        @user_id = user_id
        @vote_type = vote_type
      end

      def call
        raise "Invalid vote type" unless %w[upvote downvote].include?(vote_type)

        event =
          if vote_type == "upvote"
            Events::Events::EventUpvoted.new(data: payload)
          else
            Events::Events::EventDownvoted.new(data: payload)
          end

        event_store.publish(event, stream_name: stream_name)
      end

      private

      attr_reader :event_id, :user_id, :vote_type

      def event_store
        Rails.configuration.event_store
      end

      def payload
        {
          event_id: event_id,
          user_id: user_id
        }
      end

      def stream_name
        "Event$#{event_id}"
      end
    end
  end
end