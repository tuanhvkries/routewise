class Preference < ApplicationRecord
  has_many :trip_preferences, dependent: :destroy
  has_many :trips, through: :trip_preferences

  validates :name, presence: true, uniqueness: true
end
