require 'carrierwave/orm/activerecord'

class Simulation < ActiveRecord::Base
  SCHEDULING_ALGORITHMS = {
    "wait" => "Wait until scheduled platform is free",
    "random" => "Randomly choose free platform"
  }

  SIZING_SCALE = 5

  SINGLE_VALUE_PARAMETERS = {
    average_probability_of_complaining: { default: 15, values: 0..100 }, # percentages
    average_probability_of_getting_information: { default: 30, values: 0..100 }, # percentages
    average_probability_of_external_delay: { default: 50, values: 0..100 }, # percentages
    average_probability_of_buying_ticket: { default: 50, values: 0..100 }, # percentages
    cash_desk_count: { default: 5, values: 1..20 },
    default_platform_waiting_time: { default: 10, values: 1..60 }, # minutes
    external_delay_info_time_span: { default: 30, values: 1..60 }, # minutes
    go_to_waiting_room_min_time_span: { default: 12, values: 1..60 }, # minutes
    go_to_platform_max_time_span: { default: 5, values: 1..60 }, # minutes
    info_desk_count: { default: 7, values: 1..20 },
    internal_arrival_time: { default: 5, values: 1..60 },
    platform_count: { default: 5, values: 1..20 },
    scheduling_algorithm: { default: nil, values: SCHEDULING_ALGORITHMS.keys },
    waiting_room_capacity: { default: 200, values: 100..2000 }
  }

  RANGE_PARAMETERS = {
    arriving_passenger_count: { default: [10, 60], values: 0..150 },
    coming_time_span_with_ticket: { default: [15, 45], values: 0..60 }, # minutes
    coming_time_span_without_ticket: { default: [15, 50], values: 0..60 }, # minutes
    companion_coming_time_span: { default: [10, 20], values: 0..60 }, # minutes
    departuring_passenger_count: { default: [10, 60], values: 0..150 },
    external_delay: { default: [5, 30], values: 0..60 }, # minutes
    selling_ticket_time: { default: [1, 3], values: 0..60 }, # minutes
    serving_information_time: { default: [1, 3], values: 0..60 } # minutes
  }

  DISTRIBUTION_PARAMETERS = {
    visitor_coming_distribution: { default: [20, 30, 40, 50, 60, 70, 80, 90, 100, 90, 80, 70], type: :integer },
    companion_count_distribution: { default: [30, 30, 20, 10, 5, 5, 0], type: :float }
  }

  serialize :companion_count_distribution, Array
  serialize :visitor_coming_distribution, Array
  mount_uploader :output, GzipUploader

  before_validation :convert_distributions

  class_eval do
    PARAMETERS = SINGLE_VALUE_PARAMETERS.merge(RANGE_PARAMETERS.merge(DISTRIBUTION_PARAMETERS))
    range_parameter_names = RANGE_PARAMETERS.keys.map do |name|
      %W[max_#{name} min_#{name}]
    end.flatten

    attr_accessible *(SINGLE_VALUE_PARAMETERS.keys + DISTRIBUTION_PARAMETERS.keys + range_parameter_names)
    attr_accessible :output
  end

  validates :scheduling_algorithm, presence: true

  def parse_result
    begin
      JSON.parse(decompress_result)
    rescue JSON::ParserError
      nil
    end
  end

  def decompress_result
    return nil unless computed?
    unless @decompressed_result
      Zlib::GzipReader.open(output.file.path) do |gz|
        @decompressed_result = gz.read
      end
    end
    @decompressed_result
  end

  def compress_result
    return nil unless computed?
    @compressed_result ||= output.file.read
  end

  def save_result_from_io(io)
    case io.content_type
      when 'application/json'
        compressed_io = StringIO.new
        Zlib::GzipWriter.open(compressed_io) do |gz|
          gz.write(io.read)
        end
        self.output = compressed_io
      when 'application/gzip', 'application/x-gzip', 'application/octet-stream'
        self.output = io
      else
        return false
    end

    self.save
  end

  def computed?
    output?
  end

  def self.build_with_defaults
    self.new.tap do |s|
      SINGLE_VALUE_PARAMETERS.merge(DISTRIBUTION_PARAMETERS).each do |parameter, options|
        s.send("#{parameter}=", options[:default])
      end
      RANGE_PARAMETERS.each do |parameter, options|
        s.send("min_#{parameter}=", options[:default].first)
        s.send("max_#{parameter}=", options[:default].last)
      end
    end
  end

  def scheduling_algorithm_name
    SCHEDULING_ALGORITHMS.values.select do |algorithm|
      algorithm[:value] == scheduling_algorithm
    end.first.try(:[], :label)
  end

  def as_json(options = {})
    super options.reverse_merge(except: [:created_at, :updated_at, :result_filename], root: true)
  end

  # calls a simulation program and sends it a json with parameters with pipe, then it expects
  # data to appear on STDOUT (again with the pipe but in the opposite direction).
  def simulate
    program = ::Yetting.simulation_program
    path = build_result_path
    output = ""

    IO.popen("#{program["call"]} #{program["path"]} #{program["options"]}", 'w+') do |pipe|
      pipe.puts(self.to_json)
      pipe.close_write

      begin
        output << pipe.read until pipe.eof?
      rescue IOError
        pipe.close_read
      end
    end

    self.update_attribute(:result, output)
  end
  handle_asynchronously :simulate

  private

  def convert_distributions
    DISTRIBUTION_PARAMETERS.each do |parameter, attrs|
      if send("#{parameter}_changed?")
        value = send("#{parameter}")
        if value.is_a?(String)
          distribution = value.gsub(/^\[|\]$/, '').split(/,\s*/)
          conversion = case attrs[:type]
            when :integer then lambda { |v| v.to_f.round }
            else :to_f
          end
          self.send("#{parameter}=", distribution.map(&conversion))
        end
      end
    end
  end
end