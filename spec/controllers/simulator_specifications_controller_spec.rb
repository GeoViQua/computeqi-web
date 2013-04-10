require 'spec_helper'

describe SimulatorSpecificationsController do

  before do
    @project = FactoryGirl.create(:trained_ep)
    @spec = @project.simulator_specification
    sign_in @project.user
  end

  describe 'GET #edit' do
    context 'as owner' do
      it 'assigns the requested project to @project' do
        get :edit, emulator_project_id: @project, id: @spec
        assigns(:project).should eq(@project)
      end
    
      it 'assigns the requested simulator specification to @spec' do
        get :edit, emulator_project_id: @project, id: @spec
        assigns(:spec).should eq(@spec)
      end

      it 'renders the #edit view' do
        get :edit, emulator_project_id: @project, id: @spec
        response.should render_template :edit
      end
    end

    context 'as non-owner' do
      before { sign_in FactoryGirl.create(:another_user) }

      it 'redirects to home#index' do
        get :edit, emulator_project_id: @project, id: @spec
        response.should redirect_to root_url
      end
    end
  end

  describe 'PUT #update' do
    context 'as owner' do
      context 'with valid attributes' do
        it 'assigns the requested project to @project'
        it 'assigns the requested simulator specification to @spec'
        it "changes @spec's attributes"
        it 'redirects to the project'
        it 'handles sample values'
      end
    end

    context 'as non-owner' do
      before { sign_in FactoryGirl.create(:another_user) }

      it 'redirects to home#index'
    end
  end

  describe 'GET #index' do
    context 'as owner' do
      it 'redirects to #edit the specification' do
        get :index, emulator_project_id: @project
        response.should redirect_to edit_emulator_project_simulator_specification_path(@project, @spec)
      end
    end

    context 'as non-owner' do
      before { sign_in FactoryGirl.create(:another_user) }

      it 'redirects to home#index' do
        get :index, emulator_project_id: @project
        response.should redirect_to root_url
      end
    end
  end

end