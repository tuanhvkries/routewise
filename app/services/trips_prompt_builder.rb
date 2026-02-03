class TripsPromptBuilder
  SYSTEM_PROMPT = <<~PROMPT
    You are a travel planning assistant.
    Create realistic itineraries and transport options.
    Return ONLY valid JSON. No markdown, no code fences, no explanations.
    Budget and prices must be realistic whole numbers in EUR.
  PROMPT

  def self.instructions(trip)
    [SYSTEM_PROMPT, trip_context(trip)].compact.join("\n\n")
  end

  def self.user_prompt(trip)
    days = ((trip.end_date - trip.start_date).to_i + 1)

    <<~PROMPT
      Create a #{days}-day trip plan and 4 most practical transport options.

      HARD RULES (must follow):
    - Return ONLY valid JSON (no markdown, no code fences, no explanations).
    - For EACH day, include exactly 4 to 5 activities total.
    - Lunch and Dinner MUST be included as activities every day.
      - Lunch starts between 12:00 and 14:00
      - Dinner starts between 18:00 and 21:00
      - Title should clearly indicate it's a meal (e.g. "Lunch: ...", "Dinner: ...")
    - The remaining activities should be realistic and sequenced by time.
    - Use 24h time format "HH:MM".
    - Keep each "details" under 25 words.
    - Latitude/longitude must be numbers (use best-guess coordinates for well-known places; otherwise use city center coordinates).

      Output JSON EXACTLY like:
      {
        "transport_options": [
          {"mode":"train|flight|bus|car","duration_minutes":120,"price":45,"co2_kg":12.3,"summary":"..."}
        ],
        "itinerary": [
          {
            "day_number": 1,
            "date": "YYYY-MM-DD",
            "activities": [
              {"starts_at":"09:30","title":"...","location":"...","latitude":48.8566,"longitude":2.3522,"details":"..."}
            ]
          ]
        ]
      }
    PROMPT
  end

  def self.trip_context(trip)
    prefs = trip.preferences.pluck(:name).join(", ").presence || "none"

    <<~PROMPT
      Trip info:
      City: #{trip.city}
      Departure: #{trip.departure}
      Dates: #{trip.start_date} to #{trip.end_date}
      People: #{trip.people}
      Budget: #{trip.budget}
      Preferences: #{prefs}
      Further preferences: #{trip.further_preferences}
    PROMPT
  end
end
