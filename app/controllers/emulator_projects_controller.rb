class EmulatorProjectsController < ApplicationController
  layout :layout_by_action

  def index
    @projects = EmulatorProject.all
  end
  
  def show
    @project = EmulatorProject.find(params[:id])
  end

  def new
    @project = EmulatorProject.new
    @project.build_simulator_specification
  end

  def create
    @project = EmulatorProject.new(params[:emulator_project])
    @project.user = current_user
    
    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render action: "new"
    end
  end

  def destroy
    @project = EmulatorProject.find(params[:id])
    if @project.user == current_user and @project.destroy
      redirect_to emulator_projects_path, notice: "Project successfully deleted."
    else
      redirect_to @project, notice: "Couldn't delete project."
    end
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
