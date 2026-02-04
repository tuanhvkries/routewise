class ApplicationController < ActionController::Base
  before_action :set_nav_upcoming_trips, if: :user_signed_in?

private

def set_nav_upcoming_trips
  @nav_upcoming_trips = current_user.trips.upcoming.limit(3)
end
end
