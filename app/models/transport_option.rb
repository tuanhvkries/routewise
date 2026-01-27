class TransportOption < ApplicationRecord
  belongs_to :trip

  validates :mode, presence: true
  validates :duration_minutes, :price, numericality: { only_integer: true }, allow_nil: true
end
