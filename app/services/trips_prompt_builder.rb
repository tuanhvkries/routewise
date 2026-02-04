class TripsPromptBuilder
  SYSTEM_PROMPT = <<~PROMPT
    You are a travel planning assistant.
    Create realistic itineraries and transport options.
    Return ONLY valid JSON. No markdown, no code fences, no explanations.
    Never use placeholders like _LOOKUP, TBD, N/A, unknown, or text in numeric fields.
    All numbers must be valid JSON numbers (no trailing decimal point like 52.). Use integers or one decimal like 52.0.
    - Any decimal number MUST include at least one digit after the decimal point (e.g. 48.0 not 48.).

  PROMPT

  def self.instructions(trip)
    [SYSTEM_PROMPT, trip_context(trip)].compact.join("\n\n")
  end

  def self.user_prompt(trip)
    days = ((trip.end_date - trip.start_date).to_i + 1)

    <<~PROMPT
    Create a #{days}-day trip plan and 4 transport options (train, bus, car, and flight when allowed).

    HARD RULES (must follow):
    - Output must be strictly valid JSON. No trailing commas.
    - No extra text before or after the JSON.

    TRANSPORT OPTIONS (pure travel time, not biased toward train):
    - Provide 4 transport options with unique "mode" values.

    DISTANCE + SPEED MODEL (must use this to prevent unrealistically short durations):
    1) Compute an estimated route distance:
      - route_distance_km = straight_line_distance_km * detour_factor
      - detour_factor:
        - train: 1.25
        - car: 1.15
        - bus: 1.20
        - flight: 1.00
    2) Compute travel time using an end-to-end average speed cap (NOT peak speed):
      - duration_minutes = ceil_to_nearest_5( (route_distance_km / avg_speed_kmh) * 60 )
    3) Speed caps (avg_speed_kmh must NOT exceed):
      - train: avg_speed_kmh <= 120
      - bus: avg_speed_kmh <= 80
      - car: avg_speed_kmh <= 110
      - flight: avg_speed_kmh <= 700
    4) Train realism constraint:
      - Do NOT assume uninterrupted high-speed rail for the full route on long or cross-border trips.

    TRANSPORT PRICING & EMISSIONS:
    - "price" must be realistic, whole numbers in EUR.
    - "co2_kg" must be realistic for the mode (number, may include 1 decimal).

    ITINERARY RULES:
    - For EACH day, include exactly 4 to 5 realistic activities total.
    - Lunch between 12:00 and 14:00 and Dinner between 18:00 and 21:00 MUST be included every day.
    - Activities MUST be sorted by "starts_at" ascending (earliest → latest).
    - First activity of Day 1 must be "Arrival".
    - Last activity on the last day must be "Departure back home".
    - Times must be realistic and not overlap.

    DATE RULES:
    - Dates must be consecutive calendar days.
    - Date format MUST be: "D MMM YY" (e.g. "12 Feb 26"). Do NOT use ISO dates.

    LOCATION RULES:
    - Latitude/longitude must be numbers (not strings).
    - Use best-guess coordinates for well-known places; otherwise use city center coordinates.

    Output JSON EXACTLY like:
    {
      "transport_options": [
        {"mode":"train|flight|bus|car","duration_minutes":120,"price":45,"co2_kg":12.3,"summary":"..."}
      ],
      "itinerary": [
        {
          "day_number": 1,
          "date": "12 Feb 26",
          "activities": [
            {"starts_at":"09:30","title":"...","location":"...","latitude":48.8566,"longitude":2.3522,"details":"..."}
          ]
        }
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
