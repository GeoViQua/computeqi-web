require 'spec_helper'

describe ValidationProject do
  
  before do
    @vp = FactoryGirl.create(:validation_project)
  end

  subject { @vp }

  it { should respond_to(:user) }
end