namespace :trips do
  desc "Backfill missing image_url for trips using Unsplash API"
  task backfill_images: :environment do
    trips = Trip.where(image_url: [nil, ""])
    total = trips.count

    if total.zero?
      puts "No trips need backfilling."
      next
    end

    puts "Backfilling images for #{total} trips..."

    trips.find_each.with_index do |trip, index|
      image_url = UnsplashService.city_image(trip.city)

      if image_url.present?
        trip.update!(image_url: image_url)
        puts "  [#{index + 1}/#{total}] ✓ #{trip.city}"
      else
        puts "  [#{index + 1}/#{total}] ✗ #{trip.city} (no image found)"
      end

      # Rate limit: Unsplash allows 50 requests/hour for demo apps
      sleep 0.5
    end

    puts "Done!"
  end
end
