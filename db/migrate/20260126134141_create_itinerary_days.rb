class CreateItineraryDays < ActiveRecord::Migration[7.1]
  def change
    create_table :itinerary_days do |t|
      t.references :trip, null: false, foreign_key: true
      t.integer :day_number
      t.date :date

      t.timestamps
    end
  end
end
