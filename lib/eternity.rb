require "eternity/version"

module Eternity
  class Dataset
    def initialize(data)
      @data = data
    end
    
    def after(pointintime)
      @data.select {|d| d[:timestamp] > pointintime }
    end
    
    def before(pointintime)
      @data.select {|d| d[:timestamp] < pointintime }
    end
    
    def between(startpoint, endpoint)
      @data.select {|d| d[:timestamp] > startpoint && d[:timestamp] < endpoint }
    end
  end
end
