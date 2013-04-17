require 'spec_helper'

describe EmulatorProjectsController do

  let(:project) { FactoryGirl.create(:trained_ep) }
  let(:user) { project.user }

  before(:each) { sign_in user }

  describe 'GET #index' do
    it 'populates an array containing the users projects' do
      get :index
      assigns(:emulator_projects).should == [project]
    end
  
    it 'renders the #index view' do
      get :index
      response.should render_template :index
    end
  end
  
  describe 'GET #show' do
    context 'as owner' do
      it 'assigns the requested project to @emulator_project' do
        get :show, id: project.id
        assigns(:emulator_project).should == project
      end

      it 'renders the #show view' do
        get :show, id: project
        response.should render_template :show
      end
    end

    context 'as non-owner' do
      before(:each) { sign_in FactoryGirl.create(:another_user) }

      it 'redirects to home#index' do
        get :show, id: project
        response.should redirect_to root_url
      end
    end
  end

  describe 'GET #new' do
    it 'assigns an emulator project with simulator specification' do
      get :new
      assigns(:emulator_project).simulator_specification.should_not be_nil
    end
    
    it 'new emulator project has empty simulator specification'
    it 'renders the #new view' do
      get :new
      response.should render_template :new
    end
  end

  describe 'GET #edit' do
    context 'as owner' do
      it 'assigns the requested project to @emulator_project' do
        get :edit, id: project
        assigns(:emulator_project).should == project
      end

      it 'renders the #edit view' do
        get :edit, id: project
        response.should render_template :edit
      end
    end

    context 'as non-owner' do
      before { sign_in FactoryGirl.create(:another_user) }

      it 'redirects to home#index' do
        get :edit, id: project
        response.should redirect_to root_url
      end
    end
  end

  describe 'PUT #update' do
    context 'as owner' do
      it 'assigns the requested project to @emulator_project' do
        put :update, id: project, emulator_project: FactoryGirl.attributes_for(:trained_ep)
        assigns(:emulator_project).should == project
      end

      it "changes @emulator_project's attributes" do
        put :update, id: project, emulator_project: FactoryGirl.attributes_for(:trained_ep, name: 'diff name')
        project.reload
        project.name.should == 'diff name'
      end

      it 'redirects to the updated emulator_project' do
        put :update, id: project, emulator_project: FactoryGirl.attributes_for(:trained_ep)
        response.should redirect_to project
      end
    end

    context 'as non-owner' do
      before(:each) { sign_in FactoryGirl.create(:another_user) }

      it "does not change @emulator_project's attributes" do
        put :update, id: project, emulator_project: FactoryGirl.attributes_for(:trained_ep, name: 'diff name')
        project.reload
        project.name.should_not == 'diff name'
      end

      it 'redirects to home#index' do
        put :update, id: project, emulator_project: FactoryGirl.attributes_for(:trained_ep)
        response.should redirect_to root_url
      end
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new emulator project' do
        expect {
          post :create, FactoryGirl.attributes_for(:new_ep)
        }.to change(EmulatorProject, :count).by(1)
      end

      it 'assigns the current user to the new project' do
        post :create, FactoryGirl.attributes_for(:new_ep)
        EmulatorProject.last.user.should eq(user)
      end

      it 'redirects to the new emulator project' do
        post :create, FactoryGirl.attributes_for(:new_ep)
        response.should redirect_to EmulatorProject.last
      end
    end

    context 'with invalid attributes' do
      # don't have any validations on the model
      it 'does not save the new emulator project'
      it 're-renders the #new view'
    end
  end

  describe 'DELETE #destroy' do
    context 'as owner' do
      it 'deletes the project' do
        expect {
          delete :destroy, id: project
        }.to change(EmulatorProject, :count).by(-1)
      end

      it 'redirects to emulator_projects#index' do
        delete :destroy, id: project
        response.should redirect_to emulator_projects_url
      end
    end

    context 'as non-owner' do
      before(:each) { sign_in FactoryGirl.create(:another_user) }

      it 'does not delete the project' do
        expect {
          delete :destroy, id: project
        }.to_not change(EmulatorProject, :count).by(-1)
      end

      it 'redirects to home#index' do
        delete :destroy, id: project
        response.should redirect_to root_url
      end
    end
  end

end