require 'rubygems'

$:.unshift(File::join(File::dirname(File::dirname(__FILE__)), "lib"))

require 'airfare/properties'
require 'airfare/scraper'
require 'airfare/result_builder'

class File
  alias_method :old_puts, :puts

  def puts obj='', *arg
    Kernel.puts obj, arg

    old_puts obj.uncolorize, arg
  end
end

class Airfare
  PROPERTIES_FILENAME = "airfare.properties"
  RESULTS_FILENAME = "fares.txt"

  attr_reader :props

  def initialize
    @props = Properties.new.load_properties PROPERTIES_FILENAME # read input parameters
  end

  def departure_date
    Date.strptime(props['departure.date'], "%m/%d/%Y")
  end

  def departure_delta
    props["departure.delta"].to_i
  end

  def return_delta
    props["return.delta"].to_i
  end

  def average_interval
    props["average.interval"].to_i
  end

  def max_fare
    props["max.fare"].to_f
  end

  def discover_fares
    scraper = Scraper.new props

    File.open(RESULTS_FILENAME, 'w') do |file|
      result_builder = ResultBuilder.new file

      (0..departure_delta-1).each do |departure_pos|
        new_departure_date = date_to_s(departure_date + departure_pos)
        scraper.departure_date = new_departure_date

        (0..return_delta-1).each do |return_pos|
          new_return_date = date_to_s(departure_date + average_interval + return_pos)
          scraper.return_date = new_return_date

          result_builder.save_header new_departure_date, new_return_date
          puts "Wait..."

          begin
            content = scraper.extract

            result_builder.save_body content, max_fare
          rescue Timeout::Error => e
            puts "Error: #{e}"
          end
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