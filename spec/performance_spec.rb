require 'bundler/setup'
require 'eternity'
require 'benchmark'
require 'json'

describe "Performance" do
  before :each do
    @data = File.read(File.join(File.dirname(__FILE__), "fixtures/exampledata.json")).split("\n").map {|line| JSON.load(line.strip) }

    @dataset = Eternity::Dataset.new(@data, :time_key => "timestamp", :time_format => :epoch)

    @last_entry = Time.at(@data.last["timestamp"])
    @middle=@last_entry-43200
    @middle_plus_five=@last_entry-42900
  end
  
  it "should not get slower" do
    result = Benchmark.measure {
      10.times { @dataset.between(@middle, @middle_plus_five) }
    }.real
    result.should < 0.5
  end
  
  it "should not get slower on average" do
    results = (0..9).map do
      Benchmark.measure {
        @dataset.between(@middle, @middle_plus_five)
      }.real
    end
    (results.inject(:+) / 10).should < 0.02
  end
end