class AddSustainabilityPreference < ActiveRecord::Migration[7.1]
  def up
    Preference.reset_column_information
    Preference.find_or_create_by!(name: "Sustainability")
  end

  def down
    Preference.where(name: "Sustainability").delete_all
  end
end
