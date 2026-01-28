class DropDaysTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :days if table_exists?(:days)
  end
end
