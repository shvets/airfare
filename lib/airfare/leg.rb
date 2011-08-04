Leg = Struct.new :origination, :destination, :airline, :dummy1, :start_date, :start_minutes,
                 :end_date, :end_minutes, :stops, :dummy3,
                 :flight_number, :connection_time, :aircraft_number, :flight_class do
  def departure
    "#{start_date} #{hours(start_minutes)}"
  end

  def arrival
    "#{end_date} #{hours(end_minutes)}"
  end

  def flight_type
    flight_class == "Y" ? "Economy" : ""
  end

  def hours minutes
    "#{two_chars(minutes / 60)}:#{two_chars(minutes%60)}"
  end

  def two_chars char
    char.to_s.size == 1 ? "0#{char}" : char
  end
end
