# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_27_155311) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "itinerary_day_id", null: false
    t.time "starts_at"
    t.string "title"
    t.string "location"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_day_id"], name: "index_activities_on_itinerary_day_id"
  end

  create_table "itinerary_days", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.integer "day_number"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_itinerary_days_on_trip_id"
  end

  create_table "preferences", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transport_options", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.string "mode"
    t.integer "duration_minutes"
    t.integer "price"
    t.float "co2_kg"
    t.text "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_transport_options_on_trip_id"
  end

  create_table "trip_preferences", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_trip_preferences_on_preference_id"
    t.index ["trip_id"], name: "index_trip_preferences_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "city"
    t.string "departure"
    t.date "start_date"
    t.date "end_date"
    t.integer "budget"
    t.integer "people"
    t.text "further_preferences"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "itinerary_days"
  add_foreign_key "itinerary_days", "trips"
  add_foreign_key "transport_options", "trips"
  add_foreign_key "trip_preferences", "preferences"
  add_foreign_key "trip_preferences", "trips"
  add_foreign_key "trips", "users"
end
