require 'spec_helper'

describe InputsController do

  # show json, put js
  # nested simulator_specification_id/id

  describe 'GET #show'
    context 'as owner' do
    end

    context 'as non-owner' do
      it 'responds with 401' do
        # get :show, id: 
        response.response_code.should == 401
    end
  end

  describe 'PUT #update'
    context 'as owner' do
    end

    context 'as non-owner' do
    end
  end

end