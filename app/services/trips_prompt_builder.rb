class TripsPromptBuilder
  SYSTEM_PROMPT = <<~PROMPT
    You are a travel planning assistant API.
    Your goal is to return a valid JSON object containing transport options and a daily itinerary.

    CRITICAL OUTPUT RULES:
    1. Return ONLY raw JSON. No Markdown (```json), no introductory text, no explanations.
    2. All numbers must be integers or floats (e.g., 45 or 45.5). Never end a float with a decimal point.
    3. Nulls are allowed only if data is impossible to determine, but prefer realistic estimates.
  PROMPT

  def self.instructions(trip)
    [SYSTEM_PROMPT, trip_context(trip)].compact.join("\n\n")
  end

  def self.user_prompt(trip)
    days = ((trip.end_date - trip.start_date).to_i + 1)

    # you can calculate straight line distance in Ruby if possible
    # otherwise, rely on the LLMs general knowledge but remove strict math formulas

    <<~PROMPT
    Create a #{days}-day trip plan and up to 4 transport options.

    CONTEXT:
    Origin: #{trip.departure}
    Destination: #{trip.city}
    Dates: #{trip.start_date} to #{trip.end_date} (#{days} days)

    SECTION 1: TRANSPORT OPTIONS
    Generate 4 transport options. Each option must be one of: Flight, Train, Bus, Car.
    - If a mode is geographically impossible (e.g., Train from NY to London), OMIT IT and replace with another feasible option
    - "duration_minutes": Must include check-in/security buffers (e.g., flight time + 2h).
    - "duration_minutes": Must be realistic based on distance and mode - Flight should normally be fastest, next Car, Train and then Bus.
    - "price": Realistic total in EUR per person.
    - "co2_kg": Realistic estimate.

    SECTION 2: ITINERARY RULES
    - **Date Format**: Strictly ISO 8601 ("YYYY-MM-DD").
    - **Structure**:
      - Day 1 starts with "Arrival" (time depends on chosen transport, assume morning arrival if unspecified).
      - Final Day ends with "Departure".
    - **Activities**: 3-5 distinct items per day.
    - **Meals**:
      - Schedule Lunch (12:00-14:00) and Dinner (18:00-21:00).
      - EXCEPTION: Do not schedule meals if they conflict with Arrival/Departure times on the first/last day.
    - **Geography**: Group activities logically by neighborhood to minimize travel.
    - **Coordinates**: Provide numeric latitude/longitude.

    OUTPUT JSON SCHEMA:
    {
      "transport_options": [
        {
          "mode": "flight",
          "duration_minutes": 180,
          "price": 150,
          "co2_kg": 120.5,
          "summary": "Direct flight via AirFrance"
        }
      ],
      "itinerary": [
        {
          "day_number": 1,
          "date": "2026-02-12",
          "activities": [
            {
              "starts_at": "09:30",
              "title": "Arrival at Airport",
              "location": "CDG Airport",
              "latitude": 49.0097,
              "longitude": 2.5479,
              "details": "Land and pick up luggage."
            }
          ]
        }
      ]
    }
    PROMPT
  end

  def self.trip_context(trip)
    prefs = trip.preferences.pluck(:name).map { |s| s.gsub('"', '') }.join(", ").presence || "Standard sightseeing"
    extra_prefs = trip.further_preferences.to_s.gsub('"', '')

    <<~PROMPT
      TRIP PARAMETERS:
      People: #{trip.people}
      Budget: #{trip.budget}
      Style/Preferences: #{prefs}
      Notes: #{extra_prefs}
    PROMPT
  end
end
