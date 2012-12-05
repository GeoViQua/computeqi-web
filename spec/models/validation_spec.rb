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
  it { should respond_to(:standard_scores) }

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

      it "should have hash for :predicted value" do
        @request_hash[:predicted].class.should == Hash
      end

      it "should have :members key in :predicted hash" do
        @request_hash[:predicted].should have_key(:members)
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

    it "should have standard scores" do
      @validation.standard_scores.should_not be_nil
    end

    it "should have correct number of standard scores" do
      @validation.standard_scores.size.should == @validation.observed.size
    end
  end
end