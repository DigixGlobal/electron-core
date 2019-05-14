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

ActiveRecord::Schema.define(version: 2019_05_14_020310) do

  create_table "audits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.string "associated_id"
    t.string "associated_type"
    t.string "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "event_store_events", id: :string, limit: 36, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "event_type", null: false
    t.binary "metadata"
    t.binary "data", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
  end

  create_table "event_store_events_in_streams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.string "event_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "groups", id: :string, limit: 36, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "groups_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "group_id", null: false
    t.index ["user_id", "group_id"], name: "index_groups_users_on_user_id_and_group_id", unique: true
  end

  create_table "kycs", id: :string, limit: 36, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tier", default: 1, null: false
    t.date "expiration_date"
    t.datetime "discarded_at"
    t.string "user_id"
    t.string "officer_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.string "residence_country", limit: 150
    t.string "citizenship", limit: 150
    t.date "birthdate"
    t.integer "applying_status", default: 0
    t.string "rejection_reason", limit: 150
    t.string "approval_txhash", limit: 80
    t.string "residence_line_1", limit: 1000
    t.string "residence_line_2", limit: 1000
    t.string "residence_city", limit: 250
    t.string "residence_postal_code", limit: 25
    t.integer "residence_proof_type"
    t.integer "identification_proof_type"
    t.date "identification_proof_expiration_date"
    t.string "identification_proof_number", limit: 50
    t.text "residence_proof_image_data"
    t.text "identification_proof_image_data"
    t.text "identification_pose_image_data"
    t.index ["applying_status"], name: "index_kycs_on_applying_status"
    t.index ["discarded_at"], name: "index_kycs_on_discarded_at"
    t.index ["officer_id"], name: "index_kycs_on_officer_id"
    t.index ["user_id"], name: "index_kycs_on_user_id"
  end

  create_table "test_images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "image_data"
  end

  create_table "users", id: :string, limit: 36, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "email", limit: 254
    t.text "tokens"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "discarded_at"
    t.string "tnc_version", limit: 50, null: false
    t.string "eth_address", limit: 42
    t.integer "change_eth_address_status"
    t.string "new_eth_address", limit: 42
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["eth_address"], name: "index_users_on_eth_address", unique: true
    t.index ["new_eth_address"], name: "index_users_on_new_eth_address", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
