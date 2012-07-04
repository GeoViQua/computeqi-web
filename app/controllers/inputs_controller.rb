class InputsController < ApplicationController  
  before_filter :find_input

  def show
    respond_to do |format|
      format.json {
        render json: @input
      }
    end
  end

  def update
    @updated = @input.update_attributes(params[:input])
    @error_messages = @input.errors.full_messages
    respond_to do |format|
      format.js {
        render
      }
    end
  end

  private

  def find_input
    @input = Input.where(simulator_specification_id: params[:simulator_specification_id]).and(name: params[:id]).first
  end
end