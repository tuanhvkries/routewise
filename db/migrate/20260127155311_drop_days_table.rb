class DropDaysTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :days
  end
end
