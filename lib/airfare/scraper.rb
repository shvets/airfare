require 'mechanize'
require 'logger'

require 'airfare/retry'

class Scraper
  extend Retry

  START_PAGE_URL = "http://ticketspinner.com/airfaretickets.html"
  FLIGHT_QUOTES_URL = "http://www.airgorilla.com/Handlers/FlightQuotes.ashx"

  attr_reader :props
  attr_accessor :departure_date, :return_date

  def initialize props
    @props = props
    @agent = Mechanize.new
    #{ |a| a.log = Logger.new(STDERR) }
  end

  def extract
    # Load the website
    start_page = @agent.get(START_PAGE_URL)

    form = start_page.forms[0] # Select the first form
    prepare_form form

    sid_page = submit_form form

    tag = sid_page.body.gsub(/URL=(.*)/).first

    url = tag[4..tag.size-3]
    sid = url.gsub(/SearchId(.*)/).first[9..-1]

    flight_quotes_page = @agent.get("#{FLIGHT_QUOTES_URL}?SearchId=#{sid}")

    flight_quotes_page.body
  end

  def submit_form form
    #raise Timeout::Error
    form.submit
  end

  retry_on_timeout :submit_form, 5

  def extract_dummy
    submit_form nil

    File.open('test.json', 'r') do |f|
      f.read
    end
  end

  private

  def prepare_form form
    form['clIti_TpType'] = case props['trip.type']
      when /RoundTrip/i then
        '2'
      when /OneWay/i then
        '1'
    end

    form.csIti_Adv_OrigCity_0 = props['departure.from']
    form.csIti_Adv_DestCity_0 = props['return.from']

    form['csIti_Adv_Date_0'] = departure_date
    form['csIti_Adv_Time_0'] = props['departure.time']

    form['csIti_Adv_Date_1'] = return_date
    form['csIti_Adv_Time_1'] = props['return.time']

    form['clIti_PaxCount_Adult'] = props['adults.number']
    form['clIti_PaxCount_Child'] = props['children.number']
    form['clIti_PaxCount_InfantInLap'] = props['infants.number']
  end

  def save page, file_name
    File.open(file_name, 'w') do |f|
      f.write page.body # Print out the body
    end
  end
end

