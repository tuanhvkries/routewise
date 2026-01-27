class TripPreference < ApplicationRecord
  belongs_to :trip
  belongs_to :preference

  validates :preference_id, uniqueness: { scope: :trip_id }
end
