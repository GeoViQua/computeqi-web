class ValidationProjectsController < ApplicationController

  def index
    @projects = current_user.validation_projects
  end
  
  def show
    @project = ValidationProject.find(params[:id])
    @validation = @project.validation
    if @validation
      redirect_to @validation
    else
      redirect_to new_validation_project_validation_path(@project)
    end
  end

  def new
    @project = ValidationProject.new
  end

  def create
    @project = ValidationProject.new(params[:validation_project])
    @project.user = current_user
    
    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render action: "new"
    end
  end

  def destroy
    @project = ValidationProject.find(params[:id])
    if @project.user == current_user and @project.destroy
      redirect_to validation_projects_path, notice: "Project successfully deleted."
    else
      redirect_to @project, notice: "Couldn't delete project."
    end
  end

end
