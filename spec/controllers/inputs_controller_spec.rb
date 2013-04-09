require 'spec_helper'

describe InputsController do

  # show json, put js
  # nested simulator_specification_id/id

  before do
    @project = FactoryGirl.create(:trained_ep)
    @spec = @project.simulator_specification
    @input = @spec.inputs.first
    sign_in @project.user
  end

  describe 'GET #show' do
    context 'as owner' do
      before do
        get :show, format: :json, emulator_project_id: @project, simulator_specification_id: @spec, id: @input.name
      end

      it 'assigns the correct input' do
        assigns(:input).should eq(@input)
      end

      it 'responds with input json' do
        response.body.should eq(@input.to_json)
      end
    end

    context 'as non-owner' do
      before do
        sign_in FactoryGirl.create(:another_user)
        get :show, format: :json, emulator_project_id: @project, simulator_specification_id: @spec, id: @input.name
      end

      it 'does not assign an input' do
        assigns(:input).should be_nil
      end

      it 'does not contain a response body' do
        response.body.should be_empty
      end

      it 'responds with 401' do
        response.response_code.should eq(401)
      end
    end
  end

  describe 'PUT #update' do
    context 'as owner' do
    end

    context 'as non-owner' do
    end
  end

end