require 'spec_helper'
require 'emulatorization'

describe EmulatorValidation do

  before do
    @project = Fabricate(:emulator_project)
    @emulator_validation = @project.emulator_validation
    output = Output.where(name: 'Result').first
    puts output.inspect
    @project.emulator.output = output
  end

  # subject { @emulator_validation }
  
  # it { should belong_to(:emulator_project) }
  # it { should respond_to(:design_size) }
  # it { should have_one(:design) }
  # it { should have_one(:run) }
  # it { should respond_to(:rmse) }
  # it { should respond_to(:standard_scores) }
  # it { should respond_to(:predicted) }

  # describe "remote request object" do
  #   before do
  #     @request_object = @emulator_validation.generate
  #   end

  #   subject { @request_object }

  #   it { should_not be_nil }
  # end

  # describe "remote handling" do
  #   before do
  #     @emulator_validation.handle(Emulatorization::API.send(@emulator_validation.generate))
  #   end

  #   # @emulator_validation.rmse.should_not be_nil
  #   # standard scores
  #   # predicted contains emulator mean and variance
  # end

end