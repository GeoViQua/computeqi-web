require 'spec_helper'
require 'emulatorization'

RSpec::Matchers.define :be_valid_plot_data do
  match do |actual|
    actual.instance_of?(Hash) && actual.has_key?("x") && actual.has_key?("y")
  end
end

describe Validation do

  let(:project) { FactoryGirl.create(:validation_project) }
  let(:validation) { project.validation }

  describe "#generate" do
    describe "returned hash" do
      subject(:hash) { validation.generate }

      it { should_not be_nil }      
      it { should have_key(:type) }

      it "has correct :type value" do
        hash[:type].should == "ValidationRequest"
      end
    
      it { should have_key(:observed) }
      it { should have_key(:predicted) }

      it "has :predicted value array" do
        hash[:predicted].should be_instance_of(Array)
      end

      context "with predicted ensembles" do
        before(:each) { validation.predicted = [[1,2,3],[1,2,3]] }
        subject(:ensemble_hash) { validation.generate }

        it "has hashes in :predicted array" do
          ensemble_hash[:predicted].first.should be_instance_of(Hash)
        end

        it "has :members in :predicted array hashes" do
          ensemble_hash[:predicted].first.should have_key(:members)
        end
      end
    end
  end

  describe "#handle" do
    let(:api_response) { JSON.parse(File.read('spec/api_responses/validation.json')) }
    before(:all) { validation.handle(api_response) }

    it "sets mean bias value" do
      validation.mean_bias.should == api_response["meanBias"]
    end

    it "sets mean mae value" do
      validation.mean_mae.should == api_response["meanMAE"]
    end

    it "sets mean rmse value" do
      validation.mean_rmse.should == api_response["meanRMSE"]
    end

    it "sets mean correlation value" do
      validation.mean_correlation.should == api_response["meanCorrelation"]
    end

    it "sets median bias value" do
      validation.median_bias.should == api_response["medianBias"]
    end

    it "sets median mae value" do
      validation.median_mae.should == api_response["medianMAE"]
    end

    it "sets median rmse value" do
      validation.median_rmse.should == api_response["medianRMSE"]
    end

    it "sets median correlation value" do
      validation.median_correlation.should == api_response["medianCorrelation"]
    end

    it "sets brier score value" do
      validation.brier_score.should == api_response["brierScore"]
    end

    it "sets crps value" do
      validation.crps.should == api_response["crps"]
    end

    it "sets crps reliability value" do
      validation.crps_reliability.should == api_response["crpsReliability"]
    end

    it "sets crps resolution value" do
      validation.crps_resolution.should == api_response["crpsResolution"]
    end

    it "sets crps uncertainty value" do
      validation.crps_uncertainty.should == api_response["crpsUncertainty"]
    end

    it "sets ign score value" do
      validation.ign_score.should == api_response["ignScore"]
    end

    it "sets ign reliability value" do
      validation.ign_reliability.should == api_response["ignReliability"]
    end

    it "sets ign resolution value" do
      validation.ign_resolution.should == api_response["ignResolution"]
    end

    it "sets ign uncertainty value" do
      validation.ign_uncertainty.should == api_response["ignUncertainty"]
    end

    it "sets valid vs predicted mean plot data" do
      validation.vs_predicted_mean_plot_data.should be_valid_plot_data
    end

    it "sets valid vs predicted median plot data" do
      validation.vs_predicted_median_plot_data.should be_valid_plot_data
    end

    it "sets valid standard score plot data" do
      validation.standard_score_plot_data.should be_valid_plot_data
    end

    it "sets valid mean residual histogram data" do
      validation.mean_residual_histogram_data.should be_valid_plot_data
    end

    it "sets valid mean residual qq plot data" do
      validation.mean_residual_qq_plot_data.should be_valid_plot_data
    end

    it "sets valid median residual histogram data" do
      validation.median_residual_histogram_data.should be_valid_plot_data
    end

    it "sets valid median residual qq plot data" do
      validation.median_residual_qq_plot_data.should be_valid_plot_data
    end

    it "sets valid rank histogram plot data" do
      validation.rank_histogram_data.should be_valid_plot_data
    end

    it "sets valid reliability diagram data" do
      validation.reliability_diagram_data.should be_valid_plot_data
    end

    it "sets valid coverage plot data" do
      validation.coverage_plot_data.should be_valid_plot_data
    end
  end
end