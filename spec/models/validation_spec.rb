require 'spec_helper'

describe Validation do

  before do
    @v = FactoryGirl.create(:validation)
  end

  subject { @v }
  
  it { should respond_to(:observed) }
  it { should respond_to(:predicted) }
  it { should respond_to(:rmse) }
  it { should respond_to(:standard_scores) }
end