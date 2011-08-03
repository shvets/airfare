require 'rubygems'

$:.unshift(File::join(File::dirname(File::dirname(__FILE__)), "lib"))

require 'airfare/properties'
require 'airfare/scraper'
require 'airfare/response_parser'

puts
class File
  alias_method :old_puts, :puts
  def puts obj='', *arg
    Kernel.puts obj, arg
    old_puts obj, arg
  end
end

class Airfare
  PROPERTIES_FILENAME = "airfare.properties"
  RESULTS_FILENAME = "fares.txt"

  attr_reader :travel_helper

  def discover_fares
    props = Properties.new.load_properties PROPERTIES_FILENAME # read input parameters
    #p props

    departure_date = Date.strptime(props['departure.date'], "%m/%d/%Y")
    departure_delta = props["departure.delta"].to_i
    return_delta = props["return.delta"].to_i
    average_interval = props["average.interval"].to_i
    max_fare = props["max.fare"].to_f

    File.open(RESULTS_FILENAME, 'w') do |file|
      (0..departure_delta-1).each do |departure_pos|
        new_departure_date = date_to_s(departure_date + departure_pos)

        (0..return_delta-1).each do |return_pos|
          new_return_date = date_to_s(departure_date + average_interval + return_pos)

          scraper = Scraper.new props

          file.puts("******************* Dates: #{new_departure_date} --- #{new_return_date} *******************")
          puts "wait..."
          content = scraper.query(new_departure_date, new_return_date)

          parser = ResponseParser.new content

          parser.save_results file, max_fare
        end
      end
    end
  end

private

  def date_to_s date
    date.strftime("%m/%d/%Y")
  end
end

airfare = Airfare.new

airfare.discover_fares