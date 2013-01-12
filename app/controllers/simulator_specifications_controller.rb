class SimulatorSpecificationsController < ApplicationController
  before_filter :find_project
  layout :layout_by_project
  
  def edit
    @spec = @project.simulator_specification
  end

  def update
    @spec = @project.simulator_specification

    # parse arrays from params
    params[:simulator_specification][:inputs_attributes].each do |key, attrs|
      sample_values = attrs[:sample_values]
      if sample_values.empty?
        # don't do anything to the values
        attrs.delete(:sample_values)
      else
        attrs[:sample_values] = sample_values.split(',').collect {|value| value.to_f }
      end
    end

    if @spec.update_attributes(params[:simulator_specification])
      redirect_to @project, notice: "Simulator specification successfully updated."
    else
      render action: "edit"
    end
  end
  
  def index
    @spec = @project.simulator_specification
    redirect_to(send("edit_#{@project.class.to_s.underscore}_simulator_specification_path", @project, @spec))
  end

  def find_project
    # project could also be sensitivity, validation
    if params[:emulator_project_id] != nil
      @project = EmulatorProject.find(params[:emulator_project_id])
    else
      @project = SensitivityProject.find(params[:sensitivity_project_id])
    end
  end

  def layout_by_project
    @project.class.to_s.underscore
  end
end