require 'colorize'

require 'airfare/response_parser'

class ResultBuilder
  attr_reader :file

  def initialize file
    @file = file
  end

  def save_header departure_date, return_date
    file.puts("\n******************* Dates: #{departure_date} --- #{return_date} *******************".yellow)
  end

  def save_body content, max_fare
    parser = ResponseParser.new content

    list = parser.flights

    list.each do |flight|
      price = flight[0].to_f

      if price <= max_fare
        file.puts "\nprice: #{flight[0]}".red

        file.puts "\n---------Direct Flight----------"
        save_flight parser, flight[5][0]

        file.puts "\n---------Return Flight----------"
        save_flight parser, flight[5][1]
      end
    end
  end

private

  def save_flight parser, data
    from_airport = parser.locate_airport(data[1])
    to_airport = parser.locate_airport(data[3])

    start_trip_duration = hours data[5]
    start_red_eye = data[6].empty? ? 0 : data[6][0][1]

    file.puts "#{from_airport} to #{to_airport}"
    file.puts "Trip Duration: #{start_trip_duration}".green
    file.puts "Red Eye: This overnight flight arrives #{start_red_eye} day later." if start_red_eye > 0

    file.puts "Airline   Flight  Origination   Destination   Departure   Arrival   Stops   Aircraft  Class"

    legs = data[7]

    legs.each_with_index do |leg_hash, index|
      leg = Leg.new(*leg_hash)

      airline = parser.locate_airline(leg.airline)
      origination_airport = parser.locate_airport(leg.origination)
      destination_airport = parser.locate_airport(leg.destination)
      aircraft = parser.locate_aircraft(leg.aircraft_number)

      file.puts "#{airline}  #{leg.flight_number}  #{origination_airport}  #{destination_airport}  #{leg.departure}  #{leg.arrival}  #{leg.stops}  #{aircraft}   #{leg.flight_type}"
      file.puts "Connection in #{destination_airport[1]}, #{destination_airport[2]} for #{hours(leg.connection_time)}.".light_blue if index < legs.length-1
    end
  end

  def hours minutes
    "#{minutes / 60}.#{(minutes%60)}"
  end
end