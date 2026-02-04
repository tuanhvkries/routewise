namespace :trips do
  desc "Backfill missing image_url and itinerary_image_url for trips using Unsplash API"
  task backfill_images: :environment do
    trips = Trip.where("image_url IS NULL OR image_url = '' OR itinerary_image_url IS NULL OR itinerary_image_url = ''")
    total = trips.count

    if total.zero?
      puts "No trips need backfilling."
      next
    end

    puts "Backfilling images for #{total} trips..."

    trips.find_each.with_index do |trip, index|
      updates = {}

      if trip.image_url.blank?
        image_url = UnsplashService.city_image(trip.city)
        updates[:image_url] = image_url if image_url.present?
        sleep 0.5
      end

      if trip.itinerary_image_url.blank?
        itinerary_url = UnsplashService.city_image(trip.city, style: :skyline)
        updates[:itinerary_image_url] = itinerary_url if itinerary_url.present?
        sleep 0.5
      end

      if updates.any?
        trip.update!(updates)
        puts "  [#{index + 1}/#{total}] ✓ #{trip.city}"
      else
        puts "  [#{index + 1}/#{total}] ✗ #{trip.city} (no images found)"
      end
    end

    puts "Done!"
  end
end
