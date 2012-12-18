class Simulation < ActiveRecord::Base
  CROWD_SPEED_FUNCTIONS = {
    "logarithmic" => "Logarithmic"
  }

  SCHEDULING_ALGORITHMS = {
    "wait" => "Wait until scheduled platform is free",
    "random" => "Randomly choose free platform",
    "attrs" => "ATTRS"
  }

  PARAMETERS = {
    arriving_passenger_count: { default: [10, 800], values: 0..1_000 },
    average_probability_of_complaining: { default: 15, values: 0..100 }, # percentages
    average_probability_of_external_delay: { default: 50, values: 0..100 }, # percentages
    average_probability_of_having_companion: { default: 25, values: 0..100 }, # percentages
    average_probability_of_having_ticket: { default: 50, values: 0..100 }, # percentages
    average_share_of_visitors: { default: 25, values: 0..100 }, # percentages
    cash_desk_count: { default: 6, values: 1..20 },
    coming_time_span_with_ticket: { default: [15, 45], values: 0..60 }, # minutes
    coming_time_span_without_ticket: { default: [15, 50], values: 10..120 }, # minutes
    crowd_speed_function: { default: nil, values: CROWD_SPEED_FUNCTIONS.keys },
    default_platform_waiting_time: { default: 10, values: 1..60 }, # minutes
    departuring_passenger_count: { default: [10, 800], values: 0..1_000 },
    external_delay: { default: [5, 60], values: 0..480 }, # minutes
    external_delay_info_time_span: { default: 30, values: 1..60 }, # minutes
    go_to_waiting_room_min_time_span: { default: 12, values: 1..60 }, # minutes
    go_to_platform_max_time_span: { default: 5, values: 1..60 }, # minutes
    info_desk_count: { default: 2, values: 1..20 },
    internal_arrival_time: { default: 5, values: 1..60 },
    max_companion_count: { default: 2, values: 1..20 },
    platform_count: { default: 4, values: 1..20 },
    scheduling_algorithm: { default: nil, values: SCHEDULING_ALGORITHMS.keys },
    selling_ticket_time: { default: [5, 10], values: 0..30 }, # minutes
    serving_information_time: { default: [5, 15], values: 0..30 }, # minutes
    waiting_room_capacity: { default: 1_000, values: 100..10_000 }
  }

  class_eval do
    attr_accessible *PARAMETERS.keys
  end

  serialize :result, JSON

  def self.build_with_defaults
    self.new.tap do |s|
      PARAMETERS.each do |parameter, options|
        if options[:default].is_a?(Array)
          s.send("min_#{parameter}=", options[:default].first)
          s.send("max_#{parameter}=", options[:default].last)
        else
          s.send("#{parameter}=", options[:default])
        end
      end
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
    program = ::Yetting.simulation_program
    raw = ""

    IO.popen("#{program["call"]} #{program["path"]} #{program["options"]}", 'w+') do |pipe|
      pipe.puts self.attributes.except("created_at", "updated_at", "id", "result").to_json
      pipe.close_write

      begin
        raw << pipe.read until pipe.eof?
      rescue IOError
        pipe.close_read
      end
    end

    self.update_column(:result, raw)
  end
  handle_asynchronously :simulate

end