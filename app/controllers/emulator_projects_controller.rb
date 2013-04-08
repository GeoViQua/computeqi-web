class EmulatorProjectsController < ApplicationController
  layout :layout_by_action
  load_and_authorize_resource

  def index
  end
  
  def show
  end

  def edit
  end

  def update
    if @emulator_project.update_attributes(params[:emulator_project])
      redirect_to @emulator_project, notice: "Project successfully updated."
    else
      render action: "edit"
    end
  end

  def new
    @emulator_project.build_simulator_specification
  end

  def create
    @emulator_project = EmulatorProject.new(params[:emulator_project])
    @emulator_project.user = current_user
    
    if @emulator_project.save
      redirect_to @emulator_project, notice: "Project created successfully."
    else
      render action: "new"
    end
  end

  def destroy
    @emulator_project.destroy
    redirect_to emulator_projects_path, notice: "Project successfully deleted."
  end

  private

  def layout_by_action
    if action_name == "show"
      "emulator_project"
    else
      "application"
    end
  end
end
