class CreateTripPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :trip_preferences do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :preference, null: false, foreign_key: true

      t.timestamps
    end
  end
end
