class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.integer :go_to_waiting_room_min_time_span
      t.integer :go_to_platform_max_time_span
      t.integer :min_coming_time_span_with_ticket
      t.integer :max_coming_time_span_with_ticket
      t.integer :min_coming_time_span_without_ticket
      t.integer :max_coming_time_span_without_ticket
      t.integer :min_internal_arrival_time
      t.integer :max_internal_arrival_time
      t.integer :min_arriving_passenger_count
      t.integer :max_arriving_passenger_count
      t.integer :min_departuring_passenger_count
      t.integer :max_departuring_passenger_count
      t.integer :max_companion_count
      t.integer :average_probability_of_having_companion
      t.integer :average_probability_of_complaining
      t.integer :average_probability_of_having_ticket
      t.integer :min_serving_information_time
      t.integer :max_serving_information_time
      t.integer :min_selling_ticket_time
      t.integer :max_selling_ticket_time
      t.integer :average_share_of_visitors
      t.integer :external_delay_info_time_span
      t.integer :platform_count
      t.integer :info_desk_count
      t.integer :cash_desk_count
      t.integer :scheduling_algorithm
      t.integer :waiting_room_capacity
      t.integer :crowd_speed_function
      t.binary :result

      t.timestamps
    end
  end
end
