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
    spec = SimulatorSpecification.find(params[:simulator_specification_id])
    if can? :manage, spec.specable
      @input = spec.inputs.where(name: params[:id]).first
    else
      render json: nil, status: :unauthorized
    end 
  end
end