class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: %i[
    show edit update loading status update_preferences save export destroy
  ]

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
    @trip.progress = 0
    @trip.generation_error = nil
    @trip.image_url = UnsplashService.city_image(@trip.city)

    if @trip.save
      TripGenerationJob.perform_later(@trip.id)
      redirect_to trip_path(@trip)
    else
      @preferences = Preference.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @preferences = Preference.order(:name)
  end

  def update
    if @trip.update(trip_params)
      @trip.update!(status: "generating", progress: 0, generation_error: nil)
      TripGenerationJob.perform_later(@trip.id)
      redirect_to trip_path(@trip)
    else
      @preferences = Preference.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @days = @trip.itinerary_days.includes(:activities).order(:day_number)
    @transport_options = @trip.transport_options
    @all_preferences = Preference.order(:name)
  end

  def loading
    # loading.html.erb will poll status endpoint
  end

  def status
    render json: {
      status: @trip.status,
      progress: @trip.progress,
      generation_error: @trip.generation_error
    }
  end

  # Used by:
  # - edit/new form (updates preferences + further_preferences)
  # - show page button (updates only further_preferences)
  def update_preferences
    attrs = {
      further_preferences: params.dig(:trip, :further_preferences)
    }

    # Only update preference_ids if present, otherwise keep existing ones.
    if params.dig(:trip, :preference_ids).present?
      attrs[:preference_ids] = preference_ids_from_params
    end

    @trip.update!(attrs)
    @trip.update!(status: "generating", progress: 0, generation_error: nil)

    TripGenerationJob.perform_later(@trip.id)
    redirect_to trip_path(@trip)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to trip_path(@trip), alert: e.record.errors.full_messages.to_sentence
  end

  def save
    redirect_to trip_path(@trip), notice: "Your trip has been saved!"
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Trip deleted."
  end

  def export
    html = render_to_string(
      template: "trips/pdf",
      layout: "pdf"
    )

    pdf = WickedPdf.new.pdf_from_string(
      html,
      encoding: "UTF-8",
      enable_local_file_access: true
    )

    send_data pdf,
              filename: "routewise-#{@trip.city.parameterize}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(
      :city, :departure, :start_date, :end_date,
      :budget, :people, :further_preferences,
      preference_ids: []
    )
  end

  def preference_ids_from_params
    Array(params.dig(:trip, :preference_ids)).reject(&:blank?)
  end
end
