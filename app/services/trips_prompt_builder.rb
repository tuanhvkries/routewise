class TripsPromptBuilder
  SYSTEM_PROMPT = <<~PROMPT
    You are a travel planning assistant.
    Create realistic itineraries and transport options.
    Return ONLY valid JSON. No markdown, no code fences, no explanations.
    All numbers must be valid JSON numbers (no trailing decimal point like 52.). Use integers or one decimal like 52.0.

  PROMPT

  def self.instructions(trip)
    [SYSTEM_PROMPT, trip_context(trip)].compact.join("\n\n")
  end

  def self.user_prompt(trip)
    days = ((trip.end_date - trip.start_date).to_i + 1)

    <<~PROMPT
      Create a #{days}-day trip plan and 4 most practical transport options.

      HARD RULES (must follow):
    - JSON must be strictly valid. No trailing commas. No extra text before/after.
    - Realistic transport prices in whole numbers in EUR based on each tranport option.
    - Each tranport option's duration must be realistic based on the distance between Departure to the Destination and each transport option.
    - For EACH day, include exactly 4 to 5 realistic activities total.
    - Lunch between 12:00 and 14:00 and Dinner between 18:00 and 21:00 MUST be included as activities every day.
    - Activities MUST be sorted by "starts_at" ascending (earliest → latest).
    - First activity of Day 1 should be Arrival, last activity on the last day should be departure back home.
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
