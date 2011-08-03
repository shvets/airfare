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

  def save_results file, max_fare
    list = flights

    list.each do |flight|
      price = flight[0].to_f

      if price <= max_fare
        file.puts "price: #{flight[0]}"

        file.puts "---------Direct Flight----------"
        save_flight file, flight[5][0]

        file.puts "---------Return Flight----------"
        save_flight file, flight[5][1]
      end
    end
  end

  def save_flight file, data
    from_airport = locate_airport(data[1])
    to_airport = locate_airport(data[3])

    start_trip_duration = hours data[5]
    start_red_eye = data[6].empty? ? 0: data[6][0][1]

    file.puts "#{from_airport} to #{to_airport}"
    file.puts "Trip Duration: #{start_trip_duration}"
    file.puts "Red Eye: This overnight flight arrives #{start_red_eye} day later." if start_red_eye > 0

    file.puts "Airline   Flight  Origination   Destination   Departure   Arrival   Stops   Aircraft  Class"

    legs = data[7]

    legs.each_with_index do |leg_hash, index|
      leg = Leg.new(*leg_hash)

      airline = locate_airline(leg.airline)
      origination_airport = locate_airport(leg.origination)
      destination_airport = locate_airport(leg.destination)
      aircraft = locate_aircraft(leg.aircraft_number)

      file.puts "#{airline}  #{leg.flight_number}  #{origination_airport}  #{destination_airport}  #{leg.departure}  #{leg.arrival}  #{leg.stops}  #{aircraft}   #{leg.flight_type}"
      file.puts "Connection in #{destination_airport[1]}, #{destination_airport[2]} for #{hours(leg.connection_time)}." if index < legs.length-1
    end
  end

private

  def hours minutes
    "#{minutes / 60}.#{(minutes%60)}"
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
