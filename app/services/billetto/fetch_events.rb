# app/services/billetto/fetch_events.rb
module Billetto
  class FetchEvents
    API_URL = "https://api.billetto.com/v1/public/events"

    def initialize(client: default_client)
      @client = client
    end

    def call
      response = client.get(API_URL)

      unless response.success?
        Rails.logger.error("Billetto API failed: #{response.status}")
        return
      end

      parsed_data = JSON.parse(response.body)

      events = parsed_data["data"] || []

      events.each do |event_data|
        upsert_event(event_data)
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSON parse error: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("Unexpected error in FetchEvents: #{e.message}")
    end

    private

    attr_reader :client

    def default_client
      Faraday.new do |f|
        f.headers["Authorization"] = "Bearer #{ENV['BILLETTO_API_KEY']}"
        f.adapter Faraday.default_adapter
      end
    end

    def upsert_event(event_data)
      Event.find_or_initialize_by(external_id: event_data["id"]).tap do |event|
        event.title       = event_data["title"]
        event.description = event_data["description"]
        event.date        = parse_date(event_data["start_time"])
        event.image_url   = extract_image(event_data)

        if event.save
          Rails.logger.info("Event saved: #{event.title}")
        else
          Rails.logger.error("Event failed: #{event.errors.full_messages}")
        end
      end
    end

    def parse_date(date_str)
      Time.parse(date_str) rescue nil
    end

    def extract_image(event_data)
      event_data.dig("images", 0, "url")
    end
  end
end