# Eternity

Eternity is a gem designed to make it easier to take timed dataset and select parts of it.

## Installation

Add this line to your application's Gemfile:

    gem 'eternity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eternity

## Usage

```
data = File.read(File.join(File.dirname(__FILE__), "fixtures/exampledata.json")).split("\n").map {|line| JSON.load(line.strip) }
dataset = Eternity::Dataset.new(@data, :time_key => "timestamp", :time_format => :epoch)
last_entry_timestamp = Time.at(data.last["timestamp"])
middle=last_entry_timestamp-43200
middle_plus_five=last_entry_timestamp-42900
p dataset.between(middle, middle_plus_five)

```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
