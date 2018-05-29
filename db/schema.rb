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

ActiveRecord::Schema.define(version: 20170525231813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

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

  create_table "admin_users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "ads", force: :cascade do |t|
    t.string   "description"
    t.float    "price"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id"
    t.integer  "volume"
    t.integer  "volume_unit"
    t.string   "village"
    t.integer  "crop_type_id"
    t.integer  "status"
    t.datetime "published_at"
    t.float    "lat"
    t.float    "lng"
    t.integer  "region_id"
    t.float    "final_price"
    t.datetime "archived_at"
    t.integer  "buyer_id"
    t.string   "other_crop_type"
    t.float    "buyer_price"
    t.integer  "ad_type"
    t.integer  "district_id"
    t.integer  "ward_id"
    t.boolean  "negotiable",      default: true
    t.string   "transport_type"
  end

  add_index "ads", ["crop_type_id"], name: "index_ads_on_crop_type_id", using: :btree
  add_index "ads", ["price"], name: "index_ads_on_price", using: :btree
  add_index "ads", ["published_at"], name: "index_ads_on_published_at", using: :btree
  add_index "ads", ["region_id"], name: "index_ads_on_region_id", using: :btree
  add_index "ads", ["status"], name: "index_ads_on_status", using: :btree
  add_index "ads", ["user_id"], name: "index_ads_on_user_id", using: :btree
  add_index "ads", ["volume"], name: "index_ads_on_volume", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "call_logs", force: :cascade do |t|
    t.integer  "caller_id",   null: false
    t.integer  "receiver_id", null: false
    t.integer  "ad_id",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "author_id",  null: false
    t.integer  "ad_id",      null: false
    t.text     "body",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["ad_id"], name: "index_comments_on_ad_id", using: :btree
  add_index "comments", ["author_id"], name: "index_comments_on_author_id", using: :btree

  create_table "crop_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name_sw"
    t.integer  "sort_order"
  end

  add_index "crop_types", ["sort_order"], name: "index_crop_types_on_sort_order", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "districts", force: :cascade do |t|
    t.integer  "region_id",  null: false
    t.string   "name",       null: false
    t.float    "lat",        null: false
    t.float    "lon",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "districts", ["name"], name: "index_districts_on_name", using: :btree

  create_table "event_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorite_ads", force: :cascade do |t|
    t.integer  "ad_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorite_ads", ["ad_id"], name: "index_favorite_ads_on_ad_id", using: :btree
  add_index "favorite_ads", ["user_id"], name: "index_favorite_ads_on_user_id", using: :btree

  create_table "help_requests", force: :cascade do |t|
    t.string   "email"
    t.string   "phone_number",                 null: false
    t.text     "body",                         null: false
    t.integer  "user_id"
    t.integer  "request_type",                 null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "closed",       default: false
  end

  add_index "help_requests", ["request_type"], name: "index_help_requests_on_request_type", using: :btree

  create_table "invites", force: :cascade do |t|
    t.string   "email"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "prices", force: :cascade do |t|
    t.integer  "region_id",    null: false
    t.integer  "crop_type_id", null: false
    t.integer  "price",        null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "prices", ["created_at"], name: "index_prices_on_created_at", using: :btree
  add_index "prices", ["crop_type_id"], name: "index_prices_on_crop_type_id", using: :btree
  add_index "prices", ["region_id"], name: "index_prices_on_region_id", using: :btree
  add_index "prices", ["updated_at"], name: "index_prices_on_updated_at", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "score"
    t.integer  "rater_id"
    t.integer  "user_id"
    t.integer  "ad_id"
    t.integer  "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ratings", ["ad_id"], name: "index_ratings_on_ad_id", using: :btree
  add_index "ratings", ["rater_id"], name: "index_ratings_on_rater_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "regions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "text_logs", force: :cascade do |t|
    t.integer  "sender_id",   null: false
    t.integer  "receiver_id", null: false
    t.integer  "ad_id",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "text_messages", force: :cascade do |t|
    t.string   "to",         limit: 12
    t.string   "from",       limit: 12
    t.string   "body",                  null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "user_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_logs", ["user_id"], name: "index_user_logs_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: ""
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
    t.string   "language"
    t.float    "lat"
    t.float    "lng"
    t.integer  "region_id"
    t.float    "seller_rating"
    t.float    "buyer_rating"
    t.boolean  "agreement"
    t.string   "uid"
    t.string   "photo_url"
    t.integer  "district_id"
    t.integer  "ward_id"
    t.string   "fb_bot_id"
    t.string   "whatsapp_id"
    t.string   "gender"
    t.string   "birthday"
    t.string   "age_range"
    t.integer  "contact_credits",        default: 5
  end

  add_index "users", ["region_id"], name: "index_users_on_region_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wards", force: :cascade do |t|
    t.integer  "district_id", null: false
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "wards", ["name"], name: "index_wards_on_name", using: :btree

  create_table "whatsapp_logs", force: :cascade do |t|
    t.integer  "sender_id",   null: false
    t.integer  "receiver_id", null: false
    t.integer  "ad_id",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_foreign_key "ad_logs", "ads"
  add_foreign_key "ad_logs", "event_types"
  add_foreign_key "ad_logs", "users"
  add_foreign_key "ads", "crop_types"
  add_foreign_key "ads", "regions"
  add_foreign_key "ads", "users"
  add_foreign_key "favorite_ads", "ads"
  add_foreign_key "favorite_ads", "users"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
  add_foreign_key "ratings", "ads"
  add_foreign_key "ratings", "users"
  add_foreign_key "ratings", "users", column: "rater_id"
  add_foreign_key "user_logs", "users"
  add_foreign_key "users", "regions"
end
