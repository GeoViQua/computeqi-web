class SensitivityProjectsController < ApplicationController
  layout :layout_by_action

  def index
    @projects = SensitivityProject.all
  end
  
  def show
    @project = SensitivityProject.find(params[:id])
  end

  def new
    @project = SensitivityProject.new
    @project.build_simulator_specification
  end

  def create
    @project = SensitivityProject.new(params[:sensitivity_project])
    @project.user = current_user
    
    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render action: "new"
    end
  end

  private

  def layout_by_action
    if action_name == "show"
      "sensitivity_project"
    else
      "application"
    end
  end
end
