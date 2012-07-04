class SensitivityProject
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  
  # can either have one of these
  has_one :emulator_project
  # or one of these
  has_one :simulator_specification, as: :specable, autosave: true, dependent: :destroy
  # but always one of these
  has_one :analysis, dependent: :destroy

  # fields
  field :name, type: String

  # so we can create a spec when creating a project
  accepts_nested_attributes_for :simulator_specification

  # callbacks
  before_save :copy_name

  def complete?
    has_analysis?
  end

  def busy?
    !self.analysis.nil? and (self.analysis.in_progress? or self.analysis.queued?)
  end

  def error?
    !self.analysis.nil? and self.analysis.error?
  end

  def has_analysis?
    !self.analysis.nil? and self.analysis.success?
  end

  def uses_emulator?
    !allow_simulator_specification?
  end

  def uses_simulator?
    allow_simulator_specification?
  end

  def allow_simulator_specification?
    !self.simulator_specification.nil?
  end

  def allow_analysis?
    if allow_simulator_specification?
      simulator_specification.complete?
    else
      emulator_project.has_emulator?
    end
  end

  def needs_for_analysis
    if allow_simulator_specification?
      [ "simulator_specification" ]
    else
      [ "emulator_project" ]
    end
  end

  private

  def copy_name
    if self.name.nil?
      if !self.simulator_specification.nil?
        self.name = self.simulator_specification.process_name
      elsif !self.emulator_project.nil?
        self.name = self.emulator_project.simulator_specification.name
      end
    end
  end

end
