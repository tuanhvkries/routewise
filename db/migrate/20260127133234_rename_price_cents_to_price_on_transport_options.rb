class RenamePriceCentsToPriceOnTransportOptions < ActiveRecord::Migration[7.1]
  def change
    rename_column :transport_options, :price_cents, :price
  end
end
