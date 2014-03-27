require 'eternity/version'
module Eternity
  # This is the meat of the Gem.
  class Dataset
    include Enumerable

    def initialize(data, options = {})
      @time_key = options[:time_key] || :timestamp
      @time_format = options[:time_format] || :normal

      @hash_data = {}
      data = data.sort { |a, b| a[@time_key] <=> b[@time_key] }
      data.each do |d|
        eternity_timestamp = @time_format == :epoch ? Time.at(d[@time_key]) : d[@time_key]
        key = (eternity_timestamp - eternity_timestamp.sec).to_i
        @hash_data[key] ||= []
        @hash_data[key] << d.merge('eternity_timestamp' => eternity_timestamp)
      end
      @start_key = @hash_data.keys.min
      @end_key = @hash_data.keys.max
    end

    def each(&block)
      @hash_data.each(&block)
    end

    def after(pointintime)
       between(pointintime, Time.at(@end_key) + 120)
    end

    def before(pointintime)
      between(Time.at(@start_key) - 120, pointintime)
    end

    def between(startpoint, endpoint, time_key = 'eternity_timestamp')
      start_key = (startpoint - startpoint.sec - 60).to_i
      end_key = (endpoint + (60 - startpoint.sec)).to_i
      results = (start_key..end_key).step(60).map do |key|
        @hash_data[key]
      end.flatten.compact

      results = results.select do |d|
        d[time_key] > startpoint && d[time_key] < endpoint
      end
      results.map { |r| r.delete(time_key); r }
    end

    def previous(pointintime, time_key = 'eternity_timestamp')
      start_key = (pointintime - pointintime.sec).to_i
      key = start_key
      while (key >= @start_key)
        unless @hash_data[key] # skip to the next key
          key += 60
          next
        end
        unless @hash_data[key].select { |d| d[time_key] < pointintime }.empty?
          results = @hash_data[key].select { |d| d[time_key] < pointintime }
          results = results.sort { |a,b| a[time_key]<=>b[time_key] }
          return results.map { |r| r.delete(time_key); r }.last
        end
        key -= 60
      end
      nil
    end

    def next(pointintime, time_key = 'eternity_timestamp')
      start_key = (pointintime - pointintime.sec).to_i
      key = start_key
      while key <= @end_key
        unless @hash_data[key] # skip to the next key
          key += 60
          next
        end
        unless @hash_data[key].select { |d| d[time_key] > pointintime }.empty?
          results = @hash_data[key].select { d[time_key] > pointintime }
          results = results.sort { |a, b| a[time_key] <=> b[time_key] }
          return results.map { |r| r.delete(time_key); r }.last
        end
        key += 60
      end
      nil
    end
  end
end
