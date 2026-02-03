class AddGenerationFieldsToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :status, :string unless column_exists?(:trips, :status)
    add_column :trips, :progress, :integer, default: 0, null: false unless column_exists?(:trips, :progress)
    add_column :trips, :generation_error, :text unless column_exists?(:trips, :generation_error)

    add_index :trips, :status unless index_exists?(:trips, :status)
  end
end
