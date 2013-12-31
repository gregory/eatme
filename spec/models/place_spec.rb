require 'spec_helper'
require 'pp'
require 'rake'

describe Place do

  describe "close" do
    it "should find close places when there is" do
      close_places = Place.close(-33.0,181.0,"3.0")
      close_places[0].name.should eq "Paramount Coffee Project"
    end
    it "should not find close places when there is not" do
      close_places = Place.close(-33.0,182.0,"3.0")
      close_places.count.should eq 0
    end
    it "should raise an exception if the radius is not authorized" do
      lambda { Place.close(-33.0,182.0,"-1.0") }.should raise_error(ArgumentError)
    end
  end

  describe "popular" do
    it "should order places by popularity" do
      Information.create(name:'popular_places')
      Showmeurfood::Application.load_tasks
      Rake::Task['update_popular_places'].invoke
      popular_places = Place.popular
      popular_places[0].name.should eq "Adriatic"
      popular_places[1].name.should eq "Paramount Coffee Project"
    end
  end

  shared_examples 'rating compuration' do
    let(:place) { Place.new }
    subject { place.update_rate(rate, true) }
    context "when value.abs > #{Place::MAX_RATING}" do
      let(:value) { 10 }

      it 'raise an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'compute_rate!(value)' do
    let(:value) { 1.0 }
    let(:rate)  { 3.5 }
    let(:reviews_count) { 10 }
    let(:place) { Place.new }

    subject { place.rate }

    before do
      place.rate = rate
      place.stub(:with_lock).and_yield
      place.stub(:number_of_reviews).and_return(reviews_count)
      place.stub(:save!).and_return(true)
    end

    context 'when not new_record' do
      let(:computed_rate_for_persisted_record) { (rate * (reviews_count-1)) + value / reviews_count }

      before { place.stub(:new_record?).and_return(false) }

      it "should increase the rate by 1.0" do
        place.compute_rate!(value)
        subject.should == computed_rate_for_persisted_record
      end

      context 'when value < 0' do
        let(:value) { -3.0 }

        it 'decrease the rate' do
          place.compute_rate!(value)
          subject.should == computed_rate_for_persisted_record
        end
      end
    end

    context 'when place is new record' do
      let(:computed_rate_for_new_record) { (rate * reviews_count) + value / reviews_count + 1 }

      before { place.stub(:new_record?).and_return(true) }

      it "should increase the rate by 1.0" do
        place.compute_rate!(value)
        subject.should == computed_rate_for_new_record
      end

      context 'when value < 0' do
        let(:value) { -3.0 }

        it 'decrease the rate' do
          place.compute_rate!(value)
          subject.should ==  computed_rate_for_new_record
        end
      end
    end
  end
end
