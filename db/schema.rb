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

ActiveRecord::Schema.define(:version => 20121213191148) do

  create_table "simulations", :force => true do |t|
    t.integer  "go_to_waiting_room_min_time_span"
    t.integer  "go_to_platform_max_time_span"
    t.integer  "min_coming_time_span_with_ticket"
    t.integer  "max_coming_time_span_with_ticket"
    t.integer  "min_coming_time_span_without_ticket"
    t.integer  "max_coming_time_span_without_ticket"
    t.integer  "min_internal_arrival_time"
    t.integer  "max_internal_arrival_time"
    t.integer  "min_arriving_passenger_count"
    t.integer  "max_arriving_passenger_count"
    t.integer  "min_departuring_passenger_count"
    t.integer  "max_departuring_passenger_count"
    t.integer  "max_companion_count"
    t.integer  "average_probability_of_having_companion"
    t.integer  "average_probability_of_complaining"
    t.integer  "average_probability_of_having_ticket"
    t.integer  "min_serving_information_time"
    t.integer  "max_serving_information_time"
    t.integer  "min_selling_ticket_time"
    t.integer  "max_selling_ticket_time"
    t.integer  "average_share_of_visitors"
    t.integer  "external_delay_info_time_span"
    t.integer  "platform_count"
    t.integer  "info_desk_count"
    t.integer  "cash_desk_count"
    t.integer  "scheduling_algorithm"
    t.integer  "waiting_room_capacity"
    t.integer  "crowd_speed_function"
    t.binary   "result"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

end