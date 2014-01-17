require 'bundler/setup'
require 'eternity'
require 'benchmark'
require 'json'

describe "Performance" do
  it "should not get slower on average" do
    data = File.read(File.join(File.dirname(__FILE__), "fixtures/exampledata.json")).split("\n").map {|line| JSON.load(line.strip) }

    dataset = Eternity::Dataset.new(data, :time_key => "timestamp", :time_format => :epoch)

    last_entry = Time.at(data.last["timestamp"])
    middle=last_entry-43200
    middle_plus_five=last_entry-42900

    result = Benchmark.measure {
      10.times { dataset.between(middle, middle_plus_five) }
    }.real
    result.should < 0.5
  end
end