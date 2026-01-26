puts "🌱 Seeding RouteWise..."

Activity.destroy_all
ItineraryDay.destroy_all
TransportOption.destroy_all
TripPreference.destroy_all
Preference.destroy_all
Trip.destroy_all
User.destroy_all

demo_user = User.create!(
  email: "demo@routewise.com",
  password: "password",
  password_confirmation: "password"
)

puts "Created demo user: #{demo_user.email}"

puts "Creating preferences..."

PREFERENCES = [
  "Art",
  "Sport",
  "Museum",
  "Food",
  "Architecture",
  "Wellness",
  "Walking",
  "Relaxing",
  "Action",
  "Party",
  "Nature",
  "Shopping",
  "Local culture",
  "Photography"
]

preferences = PREFERENCES.map do |name|
  Preference.create!(name: name)
end

puts "Created #{preferences.count} preferences"

puts "Creating demo trip..."

trip = Trip.create!(
  user: demo_user,
  city: "Barcelona",
  departure: "Paris",
  start_date: Date.today + 14,
  end_date: Date.today + 16,
  budget: 60000,
  people: 2,
  further_preferences: "We like food markets and walking, no night clubs",
  status: "ready"
)

trip.preferences = preferences.sample(4)

puts "Created trip to #{trip.city}"

puts "Creating transport options..."

TransportOption.create!(
  trip: trip,
  mode: "train",
  duration_minutes: 390,
  price_cents: 6500,
  co2_kg: 12.3,
  summary: "Comfortable, low-carbon option with city-center arrival"
)

TransportOption.create!(
  trip: trip,
  mode: "plane",
  duration_minutes: 120,
  price_cents: 9000,
  co2_kg: 95.0,
  summary: "Fastest option but higher carbon footprint"
)

puts "Creating itinerary..."

(1..3).each do |day_number|
  day = ItineraryDay.create!(
    trip: trip,
    day_number: day_number,
    date: trip.start_date + (day_number - 1)
  )

  Activity.create!(
    itinerary_day: day,
    starts_at: "10:00",
    title: "Morning walk in the city",
    location: "#{trip.city} historic center",
    details: "Explore the area on foot and enjoy local architecture"
  )

  Activity.create!(
    itinerary_day: day,
    starts_at: "13:00",
    title: "Lunch at a local restaurant",
    location: trip.city,
    details: "Try a highly rated local spot within walking distance"
  )

  Activity.create!(
    itinerary_day: day,
    starts_at: "16:00",
    title: "Cultural activity",
    location: trip.city,
    details: "Museum visit or park depending on preferences"
  )
end

puts "Created itinerary with #{trip.itinerary_days.count} days"

puts "✅ Seeding completed successfully!"
