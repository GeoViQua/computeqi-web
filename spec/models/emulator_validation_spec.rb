require 'spec_helper'
require 'emulatorization'

describe EmulatorValidation do

  before do
    @project = FactoryGirl.create(:emulator_project)
    @emulator_validation = @project.emulator_validation
  end

  subject { @emulator_validation }

  it { should belong_to(:emulator_project) }
  it { should respond_to(:design_size) }
  it { should have_one(:design) }
  it { should have_one(:run) }
  it { should respond_to(:rmse) }
  it { should respond_to(:standard_scores) }
  it { should respond_to(:predicted) }

  describe "remote request hash" do
    before do
      @request_hash = @emulator_validation.generate
    end

    subject { @request_hash }

    it { should_not be_nil }
    it { should have_key(:emulator) }
    it { should have_key(:design) }
    it { should have_key(:evaluationResult) }
  end

  describe "remote request handling" do
    before do
      @emulator_validation.handle(Emulatorization::API.send(@emulator_validation.generate))
    end

    it "should have rmse" do
      @emulator_validation.rmse.should_not be_nil
    end

    it "should have standard scores" do
      @emulator_validation.standard_scores.should_not be_nil
    end

    it "should have the correct number of standard scores" do
      @emulator_validation.standard_scores.size.should == @emulator_validation.design_size
    end
  end

end