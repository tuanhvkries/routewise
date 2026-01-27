class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: %i[show loading status update_preferences save export]

  SYSTEM_PROMPT = <<~PROMPT
    You are a travel planning assistant.
    Create realistic itineraries and transport options.
    Return ONLY valid JSON. No markdown, no code fences, no explanations.
    Budget and prices must be realistic whole numbers in EUR.
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
      @trip.preference_ids = params[:trip][:preference_ids].reject(&:blank?)

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
  end

  def show
    @days = @trip.itinerary_days.includes(:activities).order(:day_number)
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

    generate_and_persist_plan!(@trip)

    @trip.update!(status: "ready")
    redirect_to trip_path(@trip)
  rescue JSON::ParserError
    @trip.update!(status: "failed")
    redirect_to trip_path(@trip), alert: "AI returned invalid data. Please try again."
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
      :budget, :people, :further_preferences
    )
  end

  # context + instructions

  def trip_context(trip)
    prefs = trip.preferences.pluck(:name).join(", ").presence || "none"

    <<~PROMPT
      Trip info:
      City: #{trip.city}
      Departure: #{trip.departure}
      Dates: #{trip.start_date} to #{trip.end_date}
      People: #{trip.people}
      Budget: #{trip.budget}
      Preferences: #{prefs}
      Further preferences: #{trip.further_preferences}
    PROMPT
  end

  def instructions(trip)
    [SYSTEM_PROMPT, trip_context(trip)].compact.join("\n\n")
  end

  def user_prompt(trip)
    days = ((trip.end_date - trip.start_date).to_i + 1)

    <<~PROMPT
      Create a #{days}-day trip plan and 3-4 transport options.

      Output JSON EXACTLY like:
      {
        "transport_options": [
          {"mode":"train|flight|bus|car","duration_minutes":120,"price":45,"co2_kg":12.3,"summary":"..."}
        ],
        "itinerary": [
          {
            "day_number": 1,
            "date": "YYYY-MM-DD",
            "activities": [
              {"starts_at":"09:30","title":"...","location":"...","details":"..."}
            ]
          }
        ]
      }
    PROMPT
  end

  # ask LLM + persist output

  def generate_and_persist_plan!(trip)
    ruby_llm_chat = RubyLLM.chat(model: "openai/gpt-5")
    response = ruby_llm_chat.with_instructions(instructions(trip)).ask(user_prompt(trip))

    data = JSON.parse(extract_json(response.content))

    ActiveRecord::Base.transaction do
      trip.transport_options.destroy_all
      trip.itinerary_days.destroy_all

      Array(data["transport_options"]).each do |t|
        trip.transport_options.create!(
          mode: t["mode"],
          duration_minutes: t["duration_minutes"],
          price: t["price"],
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
            details: a["details"]
          )
        end
      end
    end
  end

  def extract_json(text)
    start = text.index("{")
    finish = text.rindex("}")
    return text if start.nil? || finish.nil?
    text[start..finish]
  end
end
