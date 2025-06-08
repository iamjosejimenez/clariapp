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

ActiveRecord::Schema[8.0].define(version: 2025_06_08_210313) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "fintual_users", force: :cascade do |t|
    t.string "email"
    t.text "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["email"], name: "index_fintual_users_on_email", unique: true
    t.index ["user_id"], name: "index_fintual_users_on_user_id"
  end

  create_table "goal_snapshots", force: :cascade do |t|
    t.bigint "goal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "nav", null: false
    t.text "profit", null: false
    t.text "not_net_deposited", null: false
    t.text "deposited", null: false
    t.text "withdrawn", null: false
    t.date "extraction_date"
    t.index ["goal_id"], name: "index_goal_snapshots_on_goal_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "external_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "fintual_user_id", null: false
    t.string "external_created_at"
    t.text "nav", null: false
    t.text "profit", null: false
    t.text "not_net_deposited", null: false
    t.text "deposited", null: false
    t.text "withdrawn", null: false
    t.index ["fintual_user_id"], name: "index_goals_on_fintual_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "fintual_users", "users"
  add_foreign_key "goal_snapshots", "goals"
  add_foreign_key "goals", "fintual_users"
  add_foreign_key "sessions", "users"
end
