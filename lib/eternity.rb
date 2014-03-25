require 'eternity/version'

module Eternity
  class Dataset
    include Enumerable

    def initialize(data, options={})
      @time_key = options[:time_key] || :timestamp
      @time_format = options[:time_format] || :normal

      @hash_data = {}
      data = data.sort { |a, b| a[@time_key] <=> b[@time_key] }
      data.each do |datum|
        eternity_timestamp = @time_format == :epoch ? Time.at(datum[@time_key]) : datum[@time_key]
        key = (eternity_timestamp - eternity_timestamp.sec).to_i
        @hash_data[key] ||= []
        @hash_data[key] << datum.merge('eternity_timestamp' => eternity_timestamp)
      end
      @start_key = @hash_data.keys.min
      @end_key = @hash_data.keys.max
    end

    def each(&block)
      @hash_data.each(&block)
    end

    def after(pointintime)
       between(pointintime, Time.at(@end_key)+120)
    end

    def before(pointintime)
      between(Time.at(@start_key)-120, pointintime)
    end

    def between(startpoint, endpoint)
      start_key = (startpoint - startpoint.sec - 60).to_i
      end_key = (endpoint + (60-startpoint.sec)).to_i
      results = (start_key..end_key).step(60).map do |key|
        @hash_data[key]
      end.flatten.compact
      #p results
      results = results.select { |d| d['eternity_timestamp'] > startpoint && d['eternity_timestamp'] < endpoint }
      results.map {|r| x = r.dup; x.delete('eternity_timestamp'); x }
    end

    def previous(pointintime)
      start_key = (pointintime - pointintime.sec).to_i
      key = start_key
      while(key >= @start_key)
        if @hash_data[key] && !@hash_data[key].select { |d| d['eternity_timestamp'] < pointintime }.empty?
          results = @hash_data[key].select { |d| d['eternity_timestamp'] < pointintime }
          results = results.sort{|a,b| a['eternity_timestamp']<=>b['eternity_timestamp'] }
          return results.map {|r| x = r.dup; x.delete('eternity_timestamp'); x }.last
        end
        key -= 60
      end
      nil
    end

    def next(pointintime)
      time_key = 'eternity_timestamp'
      start_key = (pointintime - pointintime.sec).to_i
      key = start_key
      while key <= @end_key
        unless @hash_data[key] # skip to the next key
          key += 60
          next
        end
        unless @hash_data[key].select { |d| d[time_key] > pointintime }.empty?
          results = @hash_data[key].select do |d|
            d[time_key] > pointintime
          end
          results = results.sort do |a, b|
            a[time_key] <=> b[time_key]
          end
          return results.map do |r|
            r.delete(time_key)
            r
          end.last
        end
        key += 60
      end
      nil
    end
  end
end
