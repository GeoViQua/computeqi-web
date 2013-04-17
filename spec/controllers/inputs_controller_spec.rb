require 'spec_helper'

describe InputsController do

  let(:project) { FactoryGirl.create(:trained_ep) }
  let(:spec) { project.simulator_specification }
  let(:input) { spec.inputs.first }

  before(:each) { sign_in project.user }

  describe 'GET #show' do
    context 'as owner' do
      before do
        get :show, format: :json, emulator_project_id: project, simulator_specification_id: spec, id: input.name
      end

      it 'assigns the requested input to @input' do
        assigns(:input).should eq(input)
      end

      it 'renders @input as json' do
        response.body.should eq(input.to_json)
      end
    end

    context 'as non-owner' do
      before do
        sign_in FactoryGirl.create(:another_user)
        get :show, format: :json, emulator_project_id: project, simulator_specification_id: spec, id: input.name
      end

      it 'does not assign anything to @input' do
        assigns(:input).should be_nil
      end

      it 'responds with null' do
        response.body.should == nil.to_json
      end

      it 'responds with 401' do
        response.response_code.should == 401
      end
    end
  end

  describe 'PUT #update' do
    context 'as owner' do
      context 'with valid attributes' do
        before do
          put :update, {
            format: :js,
            emulator_project_id: project,
            simulator_specification_id: spec,
            id: input.name,
            input: { fixed_value: 0.5 }
          }
        end

        it 'assigns the requested input to @input' do
          assigns(:input).should == input
        end

        it "changes @input's attributes" do
          input.reload
          input.fixed_value.should == 0.5
        end

        it 'assigns true to @updated' do
          assigns(:updated).should == true
        end

        it 'assigns empty array to @error_messages' do
          assigns(:error_messages).should == []
        end

        it 'renders the #update view' do
          response.should render_template :update
        end
      end

      context 'with invalid attributes' do
        before do
          put :update, {
            format: :js,
            emulator_project_id: project,
            simulator_specification_id: spec,
            id: input.name,
            input: { value_type: 'super_invalid_value' }
          }
        end

        it 'assigns the requested input to @input' do
          assigns(:input).should == input
        end

        it "does not change @input's attributes" do
          input.reload
          input.fixed_value.should_not == 'super_invalid_value'
        end

        it 'assigns false to @updated' do
          assigns(:updated).should == false
        end

        it 'assigns non-empty array to @error_messages' do
          assigns(:error_messages).should_not be_empty
        end

        it 'renders the #update view' do
          response.should render_template :update
        end
      end
    end

    context 'as non-owner' do
      before do
        sign_in FactoryGirl.create(:another_user)
        put :update, {
          format: :js,
          emulator_project_id: project,
          simulator_specification_id: spec,
          id: input.name,
          input: { fixed_value: 0.5 }
        }
      end

      it 'does not assign anything to @input' do
        assigns(:input).should be_nil
      end

      it 'does not change input' do
        input.reload
        input.fixed_value.should_not == 0.5
      end

      it 'responds with null' do
        response.body.should == nil.to_json
      end

      it 'responds with 401' do
        response.response_code.should == 401
      end
    end
  end

end