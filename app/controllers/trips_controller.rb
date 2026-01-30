class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: %i[show edit update loading status update_preferences save export destroy]

  SYSTEM_PROMPT = <<~PROMPT
    Return ONLY valid JSON (no markdown/text). Double quotes only. No trailing commas.
    Prices: realistic whole EUR integers.
  PROMPT

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
      generate_and_persist_plan!(@trip)
      @trip.update!(status: "ready")
      redirect_to trip_path(@trip)
    else
      @preferences = Preference.order(:name)
      render :new, status: :unprocessable_entity
    end
  rescue JSON::ParserError
    @trip.update!(status: "failed") if @trip&.persisted?
    redirect_to new_trip_path, alert: "AI returned invalid data. Please try again."
  rescue RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, Faraday::TimeoutError, Faraday::ConnectionFailed
    @trip.update!(status: "failed") if @trip&.persisted?
    redirect_to new_trip_path, alert: "AI service is busy right now. Please try again."
  end

  def edit
    @preferences = Preference.order(:name)
  end

  def update
    if @trip.update(trip_params)
      @trip.update!(status: "generating")
      generate_and_persist_plan!(@trip)
      @trip.update!(status: "ready")
      redirect_to trip_path(@trip)
    else
      @preferences = Preference.order(:name)
      render :edit, status: :unprocessable_entity
    end
  rescue JSON::ParserError
    @trip.update!(status: "failed")
    redirect_to trip_path(@trip), alert: "AI returned invalid data. Please try again."
  rescue RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, Faraday::TimeoutError, Faraday::ConnectionFailed
    @trip.update!(status: "failed")
    redirect_to trip_path(@trip), alert: "AI service is busy right now. Please try again."
  end

  def show
    @days = @trip.itinerary_days.includes(:activities).order(:day_number)
    @transport_options = @trip.transport_options
    @all_preferences = Preference.order(:name)
  end

  def loading; end

  def status
    render json: { status: @trip.status }
  end

  # Used by:
  # - edit/new form (updates preferences + further_preferences)
  # - show page "Update further preferences" (updates only further_preferences)
  def update_preferences
    attrs = {
      further_preferences: params.dig(:trip, :further_preferences)
    }

    # Only update preference_ids if they were actually submitted,
    # otherwise we would wipe existing preferences when updating from show page.
    if params.dig(:trip, :preference_ids).present?
      attrs[:preference_ids] = preference_ids_from_params
    end

    @trip.update!(attrs)

    @trip.update!(status: "generating")
    generate_and_persist_plan!(@trip)
    @trip.update!(status: "ready")

    redirect_to trip_path(@trip), notice: "Further preferences updated."
  rescue JSON::ParserError
    @trip.update!(status: "failed")
    redirect_to trip_path(@trip), alert: "AI returned invalid data. Please try again."
  rescue RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, Faraday::TimeoutError, Faraday::ConnectionFailed
    @trip.update!(status: "failed")
    redirect_to trip_path(@trip), alert: "AI service is busy right now. Please try again."
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

  def trip_context(trip)
    prefs = trip.preferences.pluck(:name).join(", ").presence || "none"
    "city=#{trip.city}; from=#{trip.departure}; dates=#{trip.start_date}..#{trip.end_date}; people=#{trip.people}; budget=#{trip.budget}EUR; prefs=#{prefs}; notes=#{trip.further_preferences}"
  end

  def instructions(trip)
    [SYSTEM_PROMPT, trip_context(trip)].compact.join("\n\n")
  end

  def user_prompt(trip)
    days = ((trip.end_date - trip.start_date).to_i + 1)

    <<~PROMPT
      Create a #{days}-day itinerary + 4 transport options.
      Keys: transport_options, itinerary.
      transport_options: [{mode, duration_minutes, price, co2_kg, summary}]
      itinerary: [{day_number, date, activities}]
      activities: [{starts_at, title, location, latitude, longitude, details}]
      Output ONLY JSON.
    PROMPT
  end

  def generate_and_persist_plan!(trip)
    raw = ask_llm_for_plan!(trip)
    data = JSON.parse(extract_json(raw))

    ActiveRecord::Base.transaction do
      trip.transport_options.destroy_all
      trip.itinerary_days.destroy_all

      Array(data["transport_options"]).each do |t|
        trip.transport_options.create!(
          mode: t["mode"],
          duration_minutes: t["duration_minutes"],
          price: t["price"].to_i,
          co2_kg: t["co2_kg"],
          summary: t["summary"]
        )
      end

      Array(data["itinerary"]).each do |d|
        day = trip.itinerary_days.create!(
          day_number: d["day_number"],
          date: d["date"]
        )

        Array(d["activities"]).each do |a|
          day.activities.create!(
            starts_at: a["starts_at"],
            title: a["title"],
            location: a["location"],
            latitude: a["latitude"],
            longitude: a["longitude"],
            details: a["details"]
          )
        end
      end
    end
  end

  def ask_llm_for_plan!(trip)
    with_llm_retries do
      chat = RubyLLM.chat
      response =
        chat
          .with_instructions(instructions(trip))
          .ask(user_prompt(trip))

      response.content.to_s
    end
  end

  def with_llm_retries(max_attempts: 4, base_sleep: 1.0)
    attempt = 0

    begin
      attempt += 1
      yield
    rescue RubyLLM::RateLimitError, RubyLLM::ServiceUnavailableError, RubyLLM::ServerError, Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise if attempt >= max_attempts

      sleep_for = (base_sleep * (2**(attempt - 1))) + rand * 0.25
      Rails.logger.warn("[TripsController] LLM retry #{attempt}/#{max_attempts} after #{e.class}: sleeping #{sleep_for.round(2)}s")
      sleep(sleep_for)
      retry
    end
  end

  def extract_json(text)
    start = text.index("{")
    finish = text.rindex("}")
    return text if start.nil? || finish.nil?
    text[start..finish]
  end
end
