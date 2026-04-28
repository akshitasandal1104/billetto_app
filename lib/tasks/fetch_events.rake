namespace :billetto do
  desc "Fetch events from Billetto API"
  task fetch_events: :environment do
    puts "Fetching events..."

    Billetto::FetchEvents.new.call

    puts "Done!"
  end
end