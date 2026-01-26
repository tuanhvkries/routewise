class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips do |t|
      t.references :user, null: false, foreign_key: true
      t.string :city
      t.string :departure
      t.date :start_date
      t.date :end_date
      t.integer :budget
      t.integer :people
      t.text :further_preferences
      t.string :status

      t.timestamps
    end
  end
end
