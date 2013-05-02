require './spec/spec_helper'

describe Eternity do
  describe Eternity::Dataset do

    let(:ten_mins_ago_entry) { { :timestamp => Time.now-600, :value => '10 minutes ago' } }
    let(:five_mins_ago_entry) { { :timestamp => Time.now-300, :value => '5 minutes ago' } }
    let(:two_mins_ago_entry) { { :timestamp => Time.now-120, :value => '2 minutes ago' } }
    let(:one_mins_ago_entry) { { :timestamp => Time.now-60, :value => '1 minutes ago'} }
    let(:time_data) { [ten_mins_ago_entry, five_mins_ago_entry, two_mins_ago_entry, one_mins_ago_entry] }
    subject { Eternity::Dataset.new(time_data) }
    
    it "should return the data after a given point in time" do
      subject.after(Time.now-300).to_a.should == [two_mins_ago_entry, one_mins_ago_entry]
    end
    
    it "should return the data after a given point in time" do
      subject.before(Time.now-180).to_a.should == [ten_mins_ago_entry, five_mins_ago_entry]
    end
    
    it "should return the data between two given points in time" do
      subject.between(Time.now-460, Time.now-100).to_a.should == [five_mins_ago_entry, two_mins_ago_entry]
    end
  end
end