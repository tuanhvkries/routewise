class TripGenerationJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    trip = Trip.find(trip_id)
    trip.update!(status: "generating", progress: 0, generation_error: nil)

    data = LlmClient.ask_json!(
      instructions: TripsPromptBuilder.instructions(trip),
      prompt: TripsPromptBuilder.user_prompt(trip)
    )

    ActiveRecord::Base.transaction do
      trip.transport_options.destroy_all
      trip.itinerary_days.destroy_all

      Array(data["transport_options"]).each do |t|
        trip.transport_options.create!(
          mode: t["mode"],
          duration_minutes: t["duration_minutes"],
          price: t["price"].to_i,
          co2_kg: t["co2_kg"],
          summary: t["summary"]
        )
      end

      Array(data["itinerary"]).each do |d|
        day = trip.itinerary_days.create!(
          day_number: d["day_number"],
          date: d["date"]
        )

        Array(d["activities"]).each do |a|
          day.activities.create!(
            starts_at: a["starts_at"],
            title: a["title"],
            location: a["location"],
            latitude: a["latitude"],
            longitude: a["longitude"],
            details: a["details"]
          )
        end
      end
    end

    trip.update!(status: "ready", progress: 100)
  rescue JSON::ParserError => e
    trip.update!(status: "failed", generation_error: "JSON::ParserError: #{e.message}") rescue nil
    raise
  rescue => e
    trip.update!(status: "failed", generation_error: "#{e.class}: #{e.message}") rescue nil
    raise
  end
end
