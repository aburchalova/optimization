require 'spec_helper'
require_relative '../../config/initializers/float_extension.rb'

describe 'Float' do
  before { Float.stub(:COMPARISON_PRECISION => 0.01); stub_const('Float::COMPARISON_PRECISION', 0.01) }
  describe '.<=>' do

    let(:first) { 1.0 }

    context "when different by comparison precision", :focus do
      let(:second)  { first + Float::COMPARISON_PRECISION }
      # let(:third)   { first - Float::COMPARISON_PRECISION }

      # it { (first <=> second).should be_zero }
      # it { (first <=> third).should be_zero }
    end

    context "when different by less than precision" do
      let(:second)  { first + Float::COMPARISON_PRECISION / 2 }
      let(:third)   { first - Float::COMPARISON_PRECISION / 2 }

      it { (first <=> second).should be_zero }
      it { (first <=> third).should be_zero }
    end

    context "when first is less by more than precision" do
      let(:second)  { first + Float::COMPARISON_PRECISION * 2 }

      it { (first <=> second).should == -1 }
    end

    context "when first is more by more than precision" do
      let(:second)  { first - Float::COMPARISON_PRECISION * 2 }

      it { (first <=> second).should == 1 }
    end
  end

  describe 'int?' do
    it { 1.009.should be_int }
    it { 1.001.should be_int }
    it { 1.011.should_not be_int }
  end

  describe '#fractional_part' do
    it { 1.009.fractional_part.should == 0.009 }
    it { 1.0.fractional_part.should == 0 }
    it { -1.0.fractional_part.should == 0 }
    it { (-1.009).fractional_part.should == 0.991 }

    let(:integer_part) { (-1.009) - (-1.009).fractional_part }
    it { integer_part.should == -2 }
  end
end
