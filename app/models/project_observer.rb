class ProjectObserver < Mongoid::Observer
  observe :input, :design, :run, :emulator, :validation

  def after_destroy(object)
    # get project
    project = get_project(object)

    # destroy run, emulator, validation
    type = object.class

    if [ Design ].include? type
      run = project.run
      run.destroy if !run.nil?
    end

    if [ Design, Run ].include? type
      emulator = project.emulator
      emulator.destroy if !emulator.nil?
    end

    if [ Design, Run, Emulator ].include? type
      validation = project.validation
      validation.destroy if !validation.nil?
    end
  end

  def after_update(object)
    # get project
    project = get_project(object)

    # destroy everything!
    type = object.class

    if [ Input ].include? type
      # if values changed
      if object.fixed_value_changed? || object.minimum_value_changed? || object.maximum_value_changed?
        input_screening = project.input_screening
        if !input_screening.nil?
          if object.fixed?
            # if it's going to fixed, we can keep the rest of the screening
            object.screening_input_values.each {|siv| siv.destroy }
          else
            input_screening.destroy
          end
        end
        design = project.design
        design.destroy if !design.nil?
        analysis = project.analysis rescue nil
        analysis.destroy if !analysis.nil?
        run = project.run
        run.destroy if !run.nil?
        emulator = project.emulator
        emulator.destroy if !emulator.nil?
        validation = project.validation
        validation.destroy if !validation.nil?
      end
    end
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

end
