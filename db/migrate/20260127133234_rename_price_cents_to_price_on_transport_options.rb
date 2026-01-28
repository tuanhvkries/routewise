class RenamePriceCentsToPriceOnTransportOptions < ActiveRecord::Migration[7.1]
  def change
    rename_column :transport_options, :price_cents, :price if column_exists?(:transport_options, :price_cents)
  end
end
