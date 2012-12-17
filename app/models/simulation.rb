class Simulation < ActiveRecord::Base
  CROWD_SPEED_FUNCTIONS = {
    "logarithmic" => { label: "Logarithmic", value: 1 }
  }

  SCHEDULING_ALGORITHMS = {
    "wait" => { label: "Wait until scheduled platform is free", value: 1 },
    "random" => { label: "Randomly choose free platform", value: 2 },
    "attrs" => { label: "ATTRS", value: 3 }
  }

  attr_accessible :crowd_speed_function,
                  :average_probability_of_complaining,
                  :average_probability_of_having_companion,
                  :average_probability_of_having_ticket,
                  :average_share_of_visitors,
                  :cash_desk_count,
                  :default_platform_waiting_time,
                  :external_delay_info_time_span,
                  :go_to_waiting_room_min_time_span,
                  :go_to_platform_max_time_span,
                  :info_desk_count,
                  :internal_arrival_time,
                  :max_arriving_passenger_count,
                  :max_coming_time_span_with_ticket,
                  :max_coming_time_span_without_ticket,
                  :max_companion_count,
                  :max_departuring_passenger_count,
                  :max_selling_ticket_time,
                  :max_serving_information_time,
                  :min_arriving_passenger_count,
                  :min_coming_time_span_with_ticket,
                  :min_coming_time_span_without_ticket,
                  :min_departuring_passenger_count,
                  :min_selling_ticket_time,
                  :min_serving_information_time,
                  :platform_count,
                  :scheduling_algorithm,
                  :waiting_room_capacity

  serialize :result, JSON

  def self.build_with_defaults
    self.new.tap do |s|
      s.average_probability_of_complaining = 15
      s.average_probability_of_having_ticket = 50
      s.average_share_of_visitors = 25
      s.average_probability_of_having_companion = 25
      s.max_companion_count = 2
      s.cash_desk_count = 6
      s.info_desk_count = 2
      s.platform_count = 4
      s.waiting_room_capacity = 1000

      s.min_coming_time_span_with_ticket = 15
      s.max_coming_time_span_with_ticket = 45
      s.min_coming_time_span_without_ticket = 25
      s.max_coming_time_span_without_ticket = 50

      s.min_serving_information_time = 5
      s.max_serving_information_time = 15
      s.min_selling_ticket_time = 5
      s.max_selling_ticket_time = 10

      s.go_to_platform_max_time_span = 5
      s.go_to_waiting_room_min_time_span = 12

      s.min_arriving_passenger_count = 10
      s.max_arriving_passenger_count = 800
      s.min_departuring_passenger_count = 10
      s.max_departuring_passenger_count = 800

      s.external_delay_info_time_span = 30
      s.internal_arrival_time = 5
      s.default_platform_waiting_time = 10

      s.waiting_room_capacity = 1000
    end
  end

  def scheduling_algorithm_name
    SCHEDULING_ALGORITHMS.values.select do |algorithm|
      algorithm[:value] == scheduling_algorithm
    end.first.try(:[], :label)
  end

  # calls a simulation program and sends it a json with parameters with pipe, then it expects
  # data to appear on STDOUT (again with the pipe but in the opposite direction).
  def simulate
    return # program is not ready.

    Thread.new do
      program = Yettings.simulation.program
      raw = ""

      IO.popen("#{program.call} #{program.path} #{program.attributes}", 'w+') do |pipe|
        pipe.puts self.attributes.except("created_at", "updated_at", "id", "result").to_json
        pipe.close_write

        begin
          raw << pipe.read until pipe.eof?
        rescue IOError
          pipe.close_read
        end
      end

      self.result = JSON.parse(raw)
      self.save
    end
  end
  handle_asynchronously :simulate

end