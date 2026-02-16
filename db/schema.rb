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

ActiveRecord::Schema[8.1].define(version: 2026_02_14_183000) do
  create_table "budget_periods", force: :cascade do |t|
    t.integer "budget_id", null: false
    t.datetime "created_at", null: false
    t.integer "period"
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["budget_id", "year", "period"], name: "index_budget_periods_on_budget_id_and_year_and_period", unique: true
    t.index ["budget_id"], name: "index_budget_periods_on_budget_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_budgets_on_user_id"
    t.check_constraint "category IN ('mensual', 'quincenal', 'semanal')", name: "budget_category_check"
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount"
    t.integer "budget_period_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "updated_at", null: false
    t.index ["budget_period_id"], name: "index_expenses_on_budget_period_id"
  end

  create_table "external_accounts", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.string "provider"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "username"
    t.index ["user_id"], name: "index_external_accounts_on_user_id"
    t.index ["username", "provider"], name: "index_external_accounts_on_username_and_provider", unique: true
  end

  create_table "goal_snapshots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "deposited", null: false
    t.date "extraction_date", null: false
    t.integer "goal_id", null: false
    t.text "nav", null: false
    t.text "not_net_deposited", null: false
    t.text "profit", null: false
    t.datetime "updated_at", null: false
    t.text "withdrawn", null: false
    t.index ["goal_id"], name: "index_goal_snapshots_on_goal_id"
  end

  create_table "goals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "deposited", null: false
    t.integer "external_account_id"
    t.string "external_created_at"
    t.string "external_id"
    t.string "name"
    t.text "nav", null: false
    t.text "not_net_deposited", null: false
    t.text "profit", null: false
    t.datetime "updated_at", null: false
    t.text "withdrawn", null: false
    t.index ["external_account_id"], name: "index_goals_on_external_account_id"
  end

  create_table "news_items", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "news_summary_id", null: false
    t.datetime "published_at", null: false
    t.decimal "relevance_score", null: false
    t.text "snippet", null: false
    t.string "source_url", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["news_summary_id"], name: "index_news_items_on_news_summary_id"
  end

  create_table "news_summaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "generation_date", null: false
    t.integer "sources_count", default: 0, null: false
    t.text "summary", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["generation_date"], name: "index_news_summaries_on_generation_date", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "budget_periods", "budgets"
  add_foreign_key "budgets", "users"
  add_foreign_key "expenses", "budget_periods"
  add_foreign_key "external_accounts", "users"
  add_foreign_key "goal_snapshots", "goals"
  add_foreign_key "goals", "external_accounts"
  add_foreign_key "news_items", "news_summaries"
  add_foreign_key "sessions", "users"
end
