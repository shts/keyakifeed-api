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

ActiveRecord::Schema.define(version: 20160710060553) do

  create_table "entries", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "member_id"
    t.datetime "published"
    t.string   "image_url_list"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "fcms", force: :cascade do |t|
    t.string   "reg_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matomes", force: :cascade do |t|
    t.string   "feed_title"
    t.string   "feed_url"
    t.string   "feed_last_modified"
    t.string   "entry_title"
    t.string   "entry_url"
    t.datetime "entry_published"
    t.string   "image_url_list"
    t.string   "entry_categories"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "members", force: :cascade do |t|
    t.string   "name_main"
    t.string   "name_sub"
    t.string   "image_url"
    t.string   "birthday"
    t.string   "birthplace"
    t.string   "blood_type"
    t.string   "constellation"
    t.string   "height"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "favorite"
    t.string   "key"
    t.string   "status"
    t.string   "message_url"
  end

  create_table "reports", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.string   "thumbnail_url"
    t.date     "published"
    t.string   "image_url_list"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end
