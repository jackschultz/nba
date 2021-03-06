# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141209021139) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conferences", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "divisions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conference_id"
  end

  create_table "games", force: true do |t|
    t.string   "nba_id"
    t.datetime "date"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "games", ["date"], name: "index_games_on_date", using: :btree

  create_table "player_costs", force: true do |t|
    t.integer  "player_id"
    t.integer  "game_id"
    t.integer  "site_id"
    t.string   "position"
    t.integer  "salary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "expected_points"
    t.float    "actual_points_dk"
    t.boolean  "healthy",          default: true
    t.boolean  "starting",         default: false
    t.integer  "user_id"
  end

  add_index "player_costs", ["game_id"], name: "index_player_costs_on_game_id", using: :btree
  add_index "player_costs", ["site_id", "game_id", "player_id"], name: "index_player_costs_on_site_id_and_game_id_and_player_id", using: :btree

  create_table "players", force: true do |t|
    t.integer  "team_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "underscored_name"
    t.integer  "nba_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["team_id"], name: "index_players_on_team_id", using: :btree

  create_table "positions", force: true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stat_lines", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.integer  "team_id"
    t.integer  "minutes"
    t.integer  "fgm"
    t.integer  "fga"
    t.float    "fg_pct"
    t.integer  "fg3m"
    t.integer  "fg3a"
    t.float    "fg3_pct"
    t.integer  "ftm"
    t.integer  "fta"
    t.float    "ft_pct"
    t.integer  "oreb"
    t.integer  "dreb"
    t.integer  "reb"
    t.integer  "ast"
    t.integer  "stl"
    t.integer  "blk"
    t.integer  "to"
    t.integer  "pf"
    t.integer  "pts"
    t.integer  "plus_minus"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "score_draft_kings"
  end

  create_table "teams", force: true do |t|
    t.string   "nickname"
    t.string   "city"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nba_id"
    t.integer  "division_id"
    t.string   "alt_nickname"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
