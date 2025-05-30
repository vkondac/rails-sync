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

ActiveRecord::Schema[7.1].define(version: 2025_05_30_073202) do
  create_table "cars", id: :string, force: :cascade do |t|
    t.string "make", null: false
    t.string "model", null: false
    t.integer "year", null: false
    t.string "color", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "mileage", null: false
    t.string "_status", default: "synced"
    t.text "_changed"
    t.datetime "last_modified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sync_logs", force: :cascade do |t|
    t.string "table_name", null: false
    t.string "record_id", null: false
    t.string "operation", null: false
    t.bigint "timestamp", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operation"], name: "index_sync_logs_on_operation"
    t.index ["record_id"], name: "index_sync_logs_on_record_id"
    t.index ["table_name", "record_id"], name: "index_sync_logs_on_table_name_and_record_id"
    t.index ["table_name", "timestamp"], name: "index_sync_logs_on_table_name_and_timestamp"
    t.index ["timestamp"], name: "index_sync_logs_on_timestamp"
  end

end
