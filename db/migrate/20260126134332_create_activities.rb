class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :itinerary_day, null: false, foreign_key: true
      t.time :starts_at
      t.string :title
      t.string :location
      t.text :details

      t.timestamps
    end
  end
end
