require "eternity/version"

module Eternity
  class Dataset
    def initialize(data, options={})
      @time_key = options[:time_key] || :timestamp
      @time_format = options[:time_format] || :normal
      @cache_namespace = options[:cache_namespace] || "eternity-cache"
      @should_cache = options[:should_cache] || false
      data = data.sort {|a,b| a[@time_key] <=> b[@time_key] }
      if @time_format==:epoch
        @data = data.map do |datum|
          datum["timestamp"]=Time.at(datum["timestamp"])
          datum
        end
      else
        @data = data
      end
    end
    
    def after(pointintime)
      @should_cache ? after_with_cache(pointintime) : after_without_cache(pointintime)
    end
    
    def before(pointintime)
      @should_cache ? before_with_cache(pointintime) : before_without_cache(pointintime)
    end
    
    def between(startpoint, endpoint)
      @should_cache ? between_with_cache(startpoint, endpoint) : between_without_cache(startpoint, endpoint)
    end
    
    private
    def between_with_cache(startpoint, endpoint)
      rcache("between:#{startpoint.to_i}-#{endpoint.to_i}") do
        @data.select {|d| d[@time_key] > startpoint && d[@time_key] < endpoint }
      end
    end
    
    def between_without_cache(startpoint, endpoint)
      @data.select {|d| d[@time_key] > startpoint && d[@time_key] < endpoint }
    end
    
    def before_with_cache(pointintime)
      rcache("before:#{pointintime.to_i}") do
        @data.select {|d| d[@time_key] < pointintime }
      end
    end
    
    def before_without_cache(pointintime)
      @data.select {|d| d[@time_key] < pointintime }
    end
    
    def after_with_cache(pointintime)
      rcache("after:#{pointintime.to_i}") do
        @data.select {|d| d[@time_key] > pointintime }
      end
    end
    
    def after_without_cache(pointintime)
      @data.select {|d| d[@time_key] > pointintime }
    end
    
    def rcache(key)
      @redis ||= Redis.new
      data = nil
      if @redis.exists("#{@cache_namespace}:#{key}") && !(data = JSON.load(@redis.get("#{@cache_namespace}:#{key}"))).nil?
        puts "CACHE HIT: #{@cache_namespace}:#{key}" if ENV['RCACHE_DEBUG']
        #data = JSON.load(@redis.get(key))
      else
        puts "CACHE MISS: #{@cache_namespace}:#{key}" if ENV['RCACHE_DEBUG']
        data = yield
        @redis.set("#{@cache_namespace}:#{key}", data.to_json)
      end
      data = data.with_indifferent_access if data.is_a?(Hash)
      return data
    end
    
    def cache(key)
      @cache = {}
      if data = @cache["#{@cache_namespace}:#{key}"]
        puts "CACHE HIT: #{@cache_namespace}:#{key}" if ENV['CACHE_DEBUG']
      else
        puts "CACHE MISS: #{@cache_namespace}:#{key}" if ENV['CACHE_DEBUG']
        data = yield
        @cache["#{@cache_namespace}:#{key}"] = data
      end
      data = data.with_indifferent_access if data.is_a?(Hash)
      return data
    end
  end
end
