class Trip < ApplicationRecord
  belongs_to :user

  has_many :itinerary_days, dependent: :destroy
  has_many :activities, through: :itinerary_days
  has_many :transport_options, dependent: :destroy

  has_many :trip_preferences, dependent: :destroy
  has_many :preferences, through: :trip_preferences

  validates :city, :departure, :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  enum status: {
    draft: "draft",
    generating: "generating",
    ready: "ready",
    failed: "failed"
  }

  after_initialize :set_default_status, if: :new_record?

  scope :upcoming, -> {
  where("start_date >= ?", Date.current)
    .order(:start_date)
}


  private

  def set_default_status
    self.status ||= "draft"
  end

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be on or after the start date")
    end
  end
end
