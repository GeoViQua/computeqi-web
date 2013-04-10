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

      it 'assigns the requested input to @input' do
        assigns(:input).should eq(@input)
      end

      it 'renders @input as json' do
        response.body.should eq(@input.to_json)
      end
    end

    context 'as non-owner' do
      before do
        sign_in FactoryGirl.create(:another_user)
        get :show, format: :json, emulator_project_id: @project, simulator_specification_id: @spec, id: @input.name
      end

      it 'does not assign anything to @input' do
        assigns(:input).should be_nil
      end

      it 'responds with null' do
        response.body.should eq(nil.to_json)
      end

      it 'responds with 401' do
        response.response_code.should eq(401)
      end
    end
  end

  describe 'PUT #update' do
    context 'as owner' do
      context 'with valid attributes' do
        before do
          put :update, {
            format: :js,
            emulator_project_id: @project,
            simulator_specification_id: @spec,
            id: @input.name,
            input: { fixed_value: 0.5 }
          }
        end

        it 'assigns the requested input to @input' do
          assigns(:input).should eq(@input)
        end

        it "changes @input's attributes" do
          @input.reload
          @input.fixed_value.should eq(0.5)
        end

        it 'assigns true to @updated' do
          assigns(:updated).should eq(true)
        end

        it 'assigns empty array to @error_messages' do
          assigns(:error_messages).should eq([])
        end

        it 'renders the #update view' do
          response.should render_template :update
        end
      end

      context 'with invalid attributes' do
        before do
          put :update, {
            format: :js,
            emulator_project_id: @project,
            simulator_specification_id: @spec,
            id: @input.name,
            input: { value_type: 'super_invalid_value' }
          }
        end

        it 'assigns the requested input to @input' do
          assigns(:input).should eq(@input)
        end

        it "does not change @input's attributes" do
          @input.reload
          @input.fixed_value.should_not eq('super_invalid_value')
        end

        it 'assigns false to @updated' do
          assigns(:updated).should eq(false)
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
          emulator_project_id: @project,
          simulator_specification_id: @spec,
          id: @input.name,
          input: { fixed_value: 0.5 }
        }
      end

      it 'does not assign anything to @input' do
        assigns(:input).should be_nil
      end

      it 'does not change input' do
        @input.reload
        @input.fixed_value.should_not eq(0.5)
      end

      it 'responds with null' do
        response.body.should eq(nil.to_json)
      end

      it 'responds with 401' do
        response.response_code.should eq(401)
      end
    end
  end

end