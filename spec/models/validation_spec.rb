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

  it { should respond_to(:mean_bias) }
  it { should respond_to(:mean_mae) }
  it { should respond_to(:mean_rmse) }
  it { should respond_to(:mean_correlation) }
  it { should respond_to(:median_bias) }
  it { should respond_to(:median_mae) }
  it { should respond_to(:median_rmse) }
  it { should respond_to(:median_correlation) }
  it { should respond_to(:brier_score) }
  it { should respond_to(:crps) }
  it { should respond_to(:crps_reliability) }
  it { should respond_to(:crps_resolution) }
  it { should respond_to(:crps_uncertainty) }
  it { should respond_to(:ign_score) }
  it { should respond_to(:ign_reliability) }
  it { should respond_to(:ign_resolution) }
  it { should respond_to(:ign_uncertainty) }

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

    it "has key :type" do
      @request_hash.has_key(:type)
    end

    it "has :type value equal to 'ValidationRequest'" do
      @request_hash[:type].should == "ValidationRequest"
    end
    
    it "has key :observed" do
      @request_hash.has_key(:observed)
    end

    it "has key :predicted" do
      @request_hash.has_key(:predicted)
    end

    it "has array for :predicted value" do
      @request_hash[:predicted].class.should == Array
    end

    describe "with predicted ensembles" do
      before do
        # quick (and confusing) way to add ensembles
        @validation.predicted = [[1,2,3],[1,2,3]]
        @request_hash = @validation.generate
      end

      it "has hashes in :predicted array" do
        @request_hash[:predicted].first.class.should == Hash
      end

      it "has :members in :predicted array hashes" do
        @request_hash[:predicted].first.has_key(:members)
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

    it "has mean bias" do
      @validation.mean_bias.should_not be_nil
    end

    it "has mean mae" do
      @validation.mean_mae.should_not be_nil
    end

    it "has mean rmse" do
      @validation.mean_rmse.should_not be_nil
    end

    it "has mean correlation" do
      @validation.mean_correlation.should_not be_nil
    end

    it "has median bias" do
      @validation.median_bias.should_not be_nil
    end

    it "has median mae" do
      @validation.median_mae.should_not be_nil
    end

    it "has median rmse" do
      @validation.median_rmse.should_not be_nil
    end

    it "has median correlation" do
      @validation.median_correlation.should_not be_nil
    end

    it "has brier score" do
      @validation.median_correlation.should_not be_nil
    end

    it "has crps" do
      @validation.crps.should_not be_nil
    end

    it "has crps reliability" do
      @validation.crps_reliability.should_not be_nil
    end

    it "has crps resolution" do
      @validation.crps_resolution.should_not be_nil
    end

    it "has crps uncertainty" do
      @validation.crps_uncertainty.should_not be_nil
    end

    it "has ign score" do
      @validation.ign_score.should_not be_nil
    end

    it "has ign reliability" do
      @validation.ign_reliability.should_not be_nil
    end

    it "has ign resolution" do
      @validation.ign_resolution.should_not be_nil
    end

    it "has ign uncertainty" do
      @validation.ign_uncertainty.should_not be_nil
    end

    it "has vs predicted mean plot data" do
      @validation.vs_predicted_mean_plot_data.should_not be_nil
    end

    it "has vs predicted median plot data" do
      @validation.vs_predicted_median_plot_data.should_not be_nil
    end

    it "has standard score plot data" do
      @validation.standard_score_plot_data.should_not be_nil
    end

    it "has mean residual histogram data" do
      @validation.mean_residual_histogram_data.should_not be_nil
    end

    it "has mean residual qq plot data" do
      @validation.mean_residual_qq_plot_data.should_not be_nil
    end

    it "has median residual histogram data" do
      @validation.median_residual_histogram_data.should_not be_nil
    end

    it "has median residual qq plot data" do
      @validation.median_residual_qq_plot_data.should_not be_nil
    end

    it "has rank histogram plot data" do
      @validation.rank_histogram_data.should_not be_nil
    end

    it "has reliability diagram data" do
      @validation.reliability_diagram_data.should_not be_nil
    end

    it "has coverage plot data" do
      @validation.coverage_plot_data.should_not be_nil
    end
  end
end