# encoding: utf-8
require 'nokogiri'
require 'json'

PLATFORMS = 4
RAILS = 2
STATION_NAME = "Kraków Główny"

class Train
  ATTRIBUTES = [:symbol, :arrival_at, :departure_at, :from, :to, :platform, :rail, :type]
  class_eval do
    attr_accessor *ATTRIBUTES
  end

  def initialize
  end

  def type
    @type ||= if from && to
      "transit"
    elsif from
      "arrival"
    elsif to
      "departure"
    end
  end

  def merge!(other)
    (ATTRIBUTES - [:symbol, :type]).each do |attr|
      instance_eval "@#{attr} = other.#{attr} unless @#{attr}"
    end
  end

  def to_hash
    {}.tap do |hash|
      ATTRIBUTES.each do |attr|
        hash[attr] = send(attr)
      end
    end
  end
end

trains = {}

arrivals = Nokogiri::HTML(File.read("arrivals.html"))
table = arrivals.css('table.hafasResult').first
table.css('tr.arrboard-dark, tr.arrboard-light').each do |result|
  train = Train.new
  result.css('td').each_with_index do |informations, index|
    case index
    when 0
      train.arrival_at = informations.text
    when 2
      train.symbol = informations.text.strip.gsub(/\n+/, ' ')
    when 3
      train.from = informations.css('span.bold').first.text.strip
    end
  end

  trains[train.symbol] = train
end

departures = Nokogiri::HTML(File.read("departures.html"))
table = departures.css('table.hafasResult').first
table.css('tr.depboard-dark, tr.depboard-light').each do |result|
  train = Train.new
  result.css('td').each_with_index do |informations, index|
    case index
    when 0
      train.departure_at = informations.text
    when 1
      train.symbol = informations.text.strip.gsub(/\n+/, ' ')
    when 2
      train.to = informations.css('span.bold').first.text.strip
    end
  end

  if trains.include?(train.symbol)
    trains[train.symbol].merge!(train)
  else
    trains[train.symbol] = train
  end
end

# repair missing platforms and rails
trains.each do |_, train|
  train.platform ||= rand(PLATFORMS) + 1
  train.rail ||= rand(RAILS) + 1
end

File.open("schedule.json", 'w') do |f|
  f.write JSON.pretty_generate({ station: STATION_NAME, trains: trains.values.map(&:to_hash) })
end
