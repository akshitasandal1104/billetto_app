Rails.configuration.event_store = RailsEventStore::Client.new.tap do |store|
  store.subscribe(
    Events::Handlers::UpdateVoteCount.new,
    to: [Events::Events::EventUpvoted, Events::Events::EventDownvoted]
  )
end
