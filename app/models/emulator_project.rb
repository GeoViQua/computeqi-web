class EmulatorProject
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user

  # optional
  belongs_to :sensitivity_project
  
  # relationships
  has_one :simulator_specification, as: :specable, autosave: true, dependent: :destroy
  has_one :input_screening, dependent: :destroy
  has_one :design, as: :designable, dependent: :destroy
  has_one :run, as: :runnable, dependent: :destroy
  has_one :emulator, dependent: :destroy
  has_one :validation, dependent: :destroy
  
  # fields
  field :name, type: String

  # so we can create a spec when creating a project
  accepts_nested_attributes_for :simulator_specification

  # callbacks
  before_save :copy_name

  def complete?
    !self.validation.nil? and self.validation.success?
  end

  def busy?
    # horrible
    (!self.input_screening.nil? and (self.input_screening.in_progress? or self.input_screening.queued?)) or
    (!self.design.nil? and (self.design.in_progress? or self.design.in_progress?)) or
    (!self.run.nil? and (self.run.in_progress? or self.run.queued?)) or
    (!self.emulator.nil? and (self.emulator.in_progress? or self.emulator.queued?)) or
    (!self.validation.nil? and (self.validation.in_progress? or self.validation.queued?)) 
  end

  def error?
    # also horrible
    (!self.input_screening.nil? and self.input_screening.error?) or
    (!self.design.nil? and self.design.error?) or
    (!self.run.nil? and self.run.error?) or
    (!self.emulator.nil? and self.emulator.error?) or
    (!self.validation.nil? and self.validation.error?) 
  end

  def allow_simulator_specification?
    true
  end

  def allow_input_screening?
    has_simulator_specification?
  end

  def allow_design?
    has_simulator_specification?
  end

  def allow_run?
    has_design?
  end

  def allow_emulator?
    has_design? and has_run?
  end

  def allow_validation?
    has_emulator?
  end

  def has_simulator_specification?
    !self.simulator_specification.nil? and self.simulator_specification.complete?
  end

  def has_design?
    !self.design.nil? and self.design.success?
  end

  def has_run?
    !self.run.nil? and self.run.success?
  end

  def has_emulator?
    !self.emulator.nil? and self.emulator.success?
  end

  def has_validation?
    !self.validation.nil? and self.validation.success?
  end

  def needs_for_simulator_specification
    []
  end

  def needs_for_input_screening
    needs = [ "simulator_specification" ]
    needs.reject {|need| send("has_#{need}?") }  
  end  

  def needs_for_design
    needs = [ "simulator_specification" ]
    needs.reject {|need| send("has_#{need}?") }  
  end  

  def needs_for_run
    needs = [ "simulator_specification", "design" ]
    needs.reject {|need| send("has_#{need}?") }  
  end  

  def needs_for_emulator
    needs = [ "simulator_specification", "design", "run" ]
    needs.reject {|need| send("has_#{need}?") }  
  end  

  def needs_for_validation
    needs = [ "simulator_specification", "design", "run", "emulator" ]
    needs.reject {|need| send("has_#{need}?") }
  end

  private

  def copy_name
    if self.name.nil? and !self.simulator_specification.nil?
      self.name = self.simulator_specification.process_name
    end
  end
end
