class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: %i[show loading status update_preferences save export]
  def index
    @trips = current_user.trips.order(created_at: :desc)
  end

  def new
    @trip = Trip.new
    @preferences = Preference.order(:name)
  end

  def create
    @trip = current_user.trips.new(trip_params)
    @trip.status = "generating"

    if @trip.save
      @trip.preference_ids = params[:trip][:preference_ids].reject(&:blank?)
      GenerateTripJob.perform_later(@trip.id)
      redirect_to loading_trip_path(@trip)
    else
      @preferences = Preference.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @days = @trip.itinerary_days.includes(:activities)
    @transport_options = @trip.transport_options
    @all_preferences = Preference.order(:name)
  end

  def loading
  end

  def status
    render json: { status: @trip.status }
  end

  def update_preferences
    @trip.update!(
      further_preferences: params[:trip][:further_preferences],
      preference_ids: params[:trip][:preference_ids]
    )

    @trip.update!(status: "generating")
    GenerateTripJob.perform_later(@trip.id)
    redirect_to loading_trip_path(@trip)
  end

  def save
    redirect_to trip_path(@trip), notice: "Your trip has been saved!"
  end

  def export
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("trips/pdf", layout: "pdf")
    )
    send_data pdf, filename: "routewise-#{@trip.city}.pdf"
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(
      :city, :departure, :start_date, :end_date,
      :budget_cents, :people, :further_preferences
    )
  end
end
