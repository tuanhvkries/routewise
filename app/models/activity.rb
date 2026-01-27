class Activity < ApplicationRecord
  belongs_to :itinerary_day

  validates :title, :location, presence: true
end
