class SensitivityProjectsController < ApplicationController
  layout :layout_by_action

  def index
    @projects = current_user.sensitivity_projects
  end
  
  def show
    @project = SensitivityProject.find(params[:id])
  end

  def new
    @project = SensitivityProject.new
    @project.build_simulator_specification
  end

  def create
    # get emulator or simulator
    perform_with = params[:sensitivity_project].delete(:perform_with)
    emulator_project_id = params[:sensitivity_project].delete(:emulator_project)

    # create
    @project = SensitivityProject.new(params[:sensitivity_project])
    @project.user = current_user

    # check type
    if perform_with == "emulator"
      # remove simulator specification
      @project.simulator_specification = nil

      # set emulator project
      emulator_project = EmulatorProject.find(emulator_project_id)
      @project.emulator_project = emulator_project
      emulator_project.save # handle errors needed here
    end

    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render action: "new"
    end
  end

  def destroy
    @project = SensitivityProject.find(params[:id])
    if @project.destroy
      flash[:success] = "Project deleted."
    else
      flash[:error] = "Couldn't delete project."
    end
    redirect_to sensitivity_projects_path
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
