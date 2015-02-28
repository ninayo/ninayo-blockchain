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

ActiveRecord::Schema.define(version: 20150228095222) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ad_logs", force: :cascade do |t|
    t.integer  "ad_id"
    t.integer  "user_id"
    t.integer  "event_type_id"
    t.string   "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "ad_logs", ["ad_id"], name: "index_ad_logs_on_ad_id", using: :btree
  add_index "ad_logs", ["event_type_id"], name: "index_ad_logs_on_event_type_id", using: :btree
  add_index "ad_logs", ["user_id"], name: "index_ad_logs_on_user_id", using: :btree

  create_table "ads", force: :cascade do |t|
    t.string   "description"
    t.float    "price"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.integer  "volume"
    t.integer  "volume_unit"
    t.string   "village"
    t.string   "region"
    t.integer  "crop_type_id"
    t.integer  "status"
    t.datetime "published_at"
  end

  add_index "ads", ["crop_type_id"], name: "index_ads_on_crop_type_id", using: :btree
  add_index "ads", ["published_at"], name: "index_ads_on_published_at", using: :btree
  add_index "ads", ["status"], name: "index_ads_on_status", using: :btree
  add_index "ads", ["user_id"], name: "index_ads_on_user_id", using: :btree
  add_index "ads", ["volume"], name: "index_ads_on_volume", using: :btree

  create_table "crop_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.integer  "role"
    t.string   "name"
    t.string   "phone_number"
    t.string   "village"
    t.string   "region"
    t.point    "position"
    t.string   "language"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "ad_logs", "ads"
  add_foreign_key "ad_logs", "event_types"
  add_foreign_key "ad_logs", "users"
  add_foreign_key "ads", "crop_types"
  add_foreign_key "ads", "users"
end
