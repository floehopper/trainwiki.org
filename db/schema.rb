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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110402112245) do

  create_table "errors", :force => true do |t|
    t.integer  "route_id"
    t.text     "message"
    t.text     "backtrace"
    t.datetime "search_from"
    t.text     "page_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "errors", ["route_id"], :name => "index_errors_on_route_id"

  create_table "events", :force => true do |t|
    t.string   "type"
    t.integer  "journey_id"
    t.integer  "station_id"
    t.datetime "timetabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "happened_at"
  end

  add_index "events", ["journey_id"], :name => "index_events_on_journey_id"
  add_index "events", ["station_id"], :name => "index_events_on_station_id"
  add_index "events", ["timetabled_at"], :name => "index_events_on_timetabled_at"
  add_index "events", ["type"], :name => "index_events_on_type"

  create_table "journeys", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
  end

  add_index "journeys", ["identifier"], :name => "index_journeys_on_identifier"

  create_table "lines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lines", ["name"], :name => "index_lines_on_name"

  create_table "routes", :force => true do |t|
    t.integer  "line_id"
    t.integer  "origin_station_id"
    t.integer  "destination_station_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["destination_station_id"], :name => "index_routes_on_destination_station_id"
  add_index "routes", ["line_id"], :name => "index_routes_on_line_id"
  add_index "routes", ["origin_station_id"], :name => "index_routes_on_origin_station_id"

  create_table "stations", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stations", ["code"], :name => "index_stations_on_code"
  add_index "stations", ["name"], :name => "index_stations_on_name"

end
