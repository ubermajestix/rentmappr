# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090807162911) do

  create_table "houses", :force => true do |t|
    t.string   "title"
    t.string   "address"
    t.string   "href"
    t.float    "lat"
    t.float    "lng"
    t.integer  "price"
    t.text     "images_href"
    t.integer  "map_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "geocoded"
    t.boolean  "dog"
    t.boolean  "cat"
    t.string   "bedrooms"
  end

  create_table "map_areas", :force => true do |t|
    t.string   "name"
    t.string   "craigslist"
    t.integer  "expires_in"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "region"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "userhouses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "house_id"
    t.boolean  "trash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "saved"
    t.boolean  "clicked"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "map_area_id"
    t.datetime "last_visit"
  end

end
