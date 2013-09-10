require 'spec_helper'
require_relative '../../config/initializers/float_extension.rb'

describe 'Float' do
  describe '.<=>' do

    before { Float.stub(:COMPARISON_PRECISION => 0.01) }
    let(:first) { 1.0 }

    context "when different by comparison precision" do
      let(:second)  { first + Float::COMPARISON_PRECISION }
      # let(:third)   { first - Float::COMPARISON_PRECISION }

      it { (first <=> second).should be_zero }
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
end
