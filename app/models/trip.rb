class Trip < ApplicationRecord
  belongs_to :user

  has_many :itinerary_days, dependent: :destroy
  has_many :activities, through: :itinerary_days
  has_many :transport_options, dependent: :destroy

  has_many :trip_preferences, dependent: :destroy
  has_many :preferences, through: :trip_preferences

  validates :city, :departure, :start_date, :end_date, presence: true

  enum status: { generating: "generating", ready: "ready", failed: "failed" }
end
