require 'json'

require 'airfare/airport'
require 'airfare/leg'

class ResponseParser
  attr_accessor :flights, :airlines, :airports, :aircrafts

  def initialize content
    json = JSON.parse(content)

    @flights = json[1]
    @airlines = json[2]
    @airports = json[3]
    @aircrafts = json[json.size-4]
  end

  def locate_airline code
    airlines.select { |airline|
      airline[0] == code
    }.first[1]
  end

  def locate_airport code
    info = airports.select { |airport|
      airport[0] == code
    }.first

    Airport.new *info
  end

  def locate_aircraft number
    info = aircrafts.select { |aircraft|
      aircraft[0] == number
    }.first

    info[1]
  end
end
