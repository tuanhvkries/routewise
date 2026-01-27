class CreateTransportOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :transport_options do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :mode
      t.integer :duration_minutes
      t.integer :price
      t.float :co2_kg
      t.text :summary

      t.timestamps
    end
  end
end
