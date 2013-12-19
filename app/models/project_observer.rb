class ProjectObserver < Mongoid::Observer
  observe :validation

  def after_destroy(object)
    # get project and type
    project = get_project(object)
    type = object.class

    # destroy everything dependent on this one
    destroy_dependents(project, type)
  end

  def after_update(object)
    # get project and type
    project = get_project(object)
    type = object.class

    # for the rest destroy all dependent objects
    destroy_dependents(project, type)
  end

  private

  def get_project(object)
    if object.respond_to? "emulator_project"
      project = object.emulator_project
    elsif object.respond_to? "specable"
      project = object.specable
    elsif object.respond_to? "designable"
      project = object.designable
    elsif object.respond_to? "runnable"
      project = object.runnable
    elsif object.respond_to? "simulator_specification"
      project = object.simulator_specification.specable
    end
  end

  def destroy_dependents(project, type)

  end

end
