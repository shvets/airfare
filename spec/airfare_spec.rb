require 'airfare'

describe Airfare do
  subject { Airfare.new }

  it "returns flight info" do
    subject.discover_fares
  end
end
