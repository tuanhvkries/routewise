class ItineraryDay < ApplicationRecord
  belongs_to :trip
  has_many :activities, dependent: :destroy

  validates :day_number, presence: true
  validates :date, presence: true
end
