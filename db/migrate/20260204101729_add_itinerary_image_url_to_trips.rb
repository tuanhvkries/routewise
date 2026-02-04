class AddItineraryImageUrlToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :itinerary_image_url, :string
  end
end
