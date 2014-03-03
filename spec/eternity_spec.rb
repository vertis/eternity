require './spec/spec_helper'

describe Eternity::Dataset do
  let(:ten_mins_ago_entry) do
    { timestamp: Time.now - 600, value: '10 minutes ago' }
  end
  let(:five_mins_ago_entry) do
    { timestamp: Time.now - 300, value: '5 minutes ago' }
  end
  let(:two_mins_ago_entry) do
    { timestamp: Time.now - 120, value: '2 minutes ago' }
  end
  let(:one_mins_ago_entry) do
    { timestamp: Time.now - 60, value: '1 minutes ago' }
  end
  let(:time_data) do
    [
      ten_mins_ago_entry,
      five_mins_ago_entry,
      two_mins_ago_entry,
      one_mins_ago_entry
    ]
  end
  subject { Eternity::Dataset.new(time_data) }

  it 'should return the data after a given point in time' do
    entries = subject.after(Time.now - 300).to_a
    entries.should == [two_mins_ago_entry, one_mins_ago_entry]
  end

  it 'should return the data after a given point in time' do
    entries = subject.before(Time.now - 180).to_a
    entries.should == [ten_mins_ago_entry, five_mins_ago_entry]
  end

  it 'should return the data between two given points in time' do
    entries = subject.between(Time.now - 460, Time.now - 100)
    entries.to_a.should == [five_mins_ago_entry, two_mins_ago_entry]
  end

  it 'should return the previous entry to a given point in time' do
    expect(subject.previous(Time.now - 100)).to eq(two_mins_ago_entry)
  end

  it 'should return the next entry to a given point in time' do
    expect(subject.next(Time.now - 100)).to eq(one_mins_ago_entry)
  end

  context 'unordered data' do
    let(:unordered_time_data) do
      [
        five_mins_ago_entry,
        ten_mins_ago_entry,
        one_mins_ago_entry,
        two_mins_ago_entry
      ]
    end
    subject { Eternity::Dataset.new(unordered_time_data) }

    it 'should return the data after a given point in time' do
      entries = subject.after(Time.now - 300).to_a
      entries.should == [two_mins_ago_entry, one_mins_ago_entry]
    end

    it 'should return the data after a given point in time' do
      entries = subject.before(Time.now - 180).to_a
      entries.should == [ten_mins_ago_entry, five_mins_ago_entry]
    end

    it 'should return the data between two given points in time' do
      entries = subject.between(Time.now - 460, Time.now - 100).to_a
      entries.should == [five_mins_ago_entry, two_mins_ago_entry]
    end
  end
end
