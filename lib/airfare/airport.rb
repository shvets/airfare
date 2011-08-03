Airport = Struct.new :code, :name, :city, :country_code, :country do
  def to_s
    "#{city}, #{country_code}, #{name} (#{code})"
  end
end
