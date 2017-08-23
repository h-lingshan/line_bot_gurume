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

ActiveRecord::Schema.define(version: 20170821172951) do

  create_table "addresses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "foods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "last_dialogue_infos", force: :cascade do |t|
    t.string "mid"
    t.string "mode"
    t.integer "da"
    t.string "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logs", force: :cascade do |t|
    t.string "user_name"
    t.string "type"
    t.string "content"
    t.string "parent_id"
    t.string "children_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "talk_data", force: :cascade do |t|
    t.string "user_id"
    t.string "type"
    t.string "content"
    t.string "current_qid"
    t.string "parent_qid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
