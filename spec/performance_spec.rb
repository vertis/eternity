require 'bundler/setup'
require 'eternity'
require 'benchmark'
require 'json'

describe 'Performance' do
  before :each do
    dir = File.dirname(__FILE__)
    example_data_file = File.join(dir, 'fixtures/exampledata.json')
    rawdata = File.read(example_data_file)
    @data = rawdata.split("\n").map { |line| JSON.load(line.strip) }

    @dataset = Eternity::Dataset.new(@data, time_key: 'timestamp',
                                            time_format: :epoch)

    @last_entry = Time.at(@data.last['timestamp'])
    @middle = @last_entry - 43_200
    @middle_plus_five = @last_entry - 42_900
  end

  it 'should not get slower' do
    result = Benchmark.measure do
      10.times { @dataset.between(@middle, @middle_plus_five) }
    end.real
    result.should < 0.5
  end

  it 'should not get slower on average' do
    results = (0..9).map do
      Benchmark.measure do
        @dataset.between(@middle, @middle_plus_five)
      end.real
    end
    (results.inject(:+) / 10).should < 0.02
  end
end
