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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130105142027) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "simulations", :force => true do |t|
    t.integer  "go_to_waiting_room_min_time_span"
    t.integer  "go_to_platform_max_time_span"
    t.integer  "min_coming_time_span_with_ticket"
    t.integer  "max_coming_time_span_with_ticket"
    t.integer  "min_coming_time_span_without_ticket"
    t.integer  "max_coming_time_span_without_ticket"
    t.integer  "internal_arrival_time"
    t.integer  "min_arriving_passenger_count"
    t.integer  "max_arriving_passenger_count"
    t.integer  "min_departuring_passenger_count"
    t.integer  "max_departuring_passenger_count"
    t.integer  "average_probability_of_complaining"
    t.integer  "average_probability_of_buying_ticket"
    t.integer  "min_serving_information_time"
    t.integer  "max_serving_information_time"
    t.integer  "min_selling_ticket_time"
    t.integer  "max_selling_ticket_time"
    t.integer  "external_delay_info_time_span"
    t.integer  "platform_count"
    t.integer  "info_desk_count"
    t.integer  "cash_desk_count"
    t.string   "scheduling_algorithm"
    t.integer  "waiting_room_capacity"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "default_platform_waiting_time"
    t.integer  "min_external_delay"
    t.integer  "max_external_delay"
    t.integer  "average_probability_of_external_delay"
    t.integer  "min_companion_coming_time_span"
    t.integer  "max_companion_coming_time_span"
    t.string   "result_filename"
    t.binary   "companion_count_distribution"
    t.binary   "crowd_speed_distribution"
    t.binary   "visitor_coming_distribution"
    t.float    "subway_width"
    t.float    "subway_length"
    t.float    "hall_width"
    t.float    "hall_length"
    t.integer  "average_probability_of_getting_information"
  end

end
