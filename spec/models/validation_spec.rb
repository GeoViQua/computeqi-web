require 'spec_helper'
require 'emulatorization'

describe Validation do

  before do
    @project = FactoryGirl.create(:validation_project)
    @validation = @project.validation
  end

  subject { @validation }
  
  it { should respond_to(:observed) }
  it { should respond_to(:predicted) }
  it { should respond_to(:rmse) }
  it { should respond_to(:vs_predicted_mean_plot_data) }
  it { should respond_to(:vs_predicted_median_plot_data) }
  it { should respond_to(:standard_score_plot_data) }
  it { should respond_to(:mean_residual_histogram_data) }
  it { should respond_to(:mean_residual_qq_plot_data) }
  it { should respond_to(:median_residual_histogram_data) }
  it { should respond_to(:median_residual_qq_plot_data) }
  it { should respond_to(:rank_histogram_data) }
  it { should respond_to(:reliability_diagram_data) }
  it { should respond_to(:coverage_plot_data) }

  describe "remote request hash" do
    before do
      @request_hash = @validation.generate
    end

    it "should not be nil" do
      @request_hash.should_not be_nil
    end

    it "should have key :type" do
      @request_hash.should have_key(:type)
    end

    it "should have :type value equal to 'ValidationRequest'" do
      @request_hash[:type].should == "ValidationRequest"
    end
    
    it "should have key :observed" do
      @request_hash.should have_key(:observed)
    end

    it "should have key :predicted" do
      @request_hash.should have_key(:predicted)
    end

    it "should have array for :predicted value" do
      @request_hash[:predicted].class.should == Array
    end

    describe "with predicted ensembles" do
      before do
        # quick (and confusing) way to add ensembles
        @validation.predicted = [[1,2,3],[1,2,3]]
        @request_hash = @validation.generate
      end

      it "should have hashes in :predicted array" do
        @request_hash[:predicted].first.class.should == Hash
      end

      it "should have :members in :predicted array hashes" do
        @request_hash[:predicted].first.should have_key(:members)
      end
    end
  end

  describe "after remote request" do
    before do
      response = Emulatorization::API.send(@validation.generate)
      if response["type"] == "Exception"
        raise response["message"] || response["source"]
      end
      @validation.handle(response)
    end

    it "should have rmse" do
      @validation.rmse.should_not be_nil
    end

    it "should have vs predicted mean plot data" do
      @validation.vs_predicted_mean_plot_data.should_not be_nil
    end

    it "should have vs predicted median plot data" do
      @validation.vs_predicted_median_plot_data.should_not be_nil
    end

    it "should have standard score plot data" do
      @validation.standard_score_plot_data.should_not be_nil
    end

    it "should have mean residual histogram data" do
      @validation.mean_residual_histogram_data.should_not be_nil
    end

    it "should have mean residual qq plot data" do
      @validation.mean_residual_qq_plot_data.should_not be_nil
    end

    it "should have median residual histogram data" do
      @validation.median_residual_histogram_data.should_not be_nil
    end

    it "should have median residual qq plot data" do
      @validation.median_residual_qq_plot_data.should_not be_nil
    end

    it "should have rank histogram plot data" do
      @validation.rank_histogram_data.should_not be_nil
    end

    it "should have reliability diagram data" do
      @validation.reliability_diagram_data.should_not be_nil
    end

    it "should have coverage plot data" do
      @validation.coverage_plot_data.should_not be_nil
    end
  end
end