class Validation
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :emulator_project
  has_many :validation_values
  
  field :design_size, type: Integer

  field :emulator_time, type: Integer

  has_one :design, as: :designable
  has_one :run, as: :runnable

  # validation needs to check that design_size is not greater than emulator.validation_indicies.size
  # 

  def calculate_defaults
    self.design_size = self.emulator_project.emulator.validation_indices.size
  end
  
  def to_hash
    { emulatorTime: self.emulator_time,
      outputResults: self.validation_values.collect {|value| value.to_hash } }
  end
  
  def generate
    # get project and spec
    project = self.emulator_project
    spec = project.simulator_specification
    emulator = project.emulator
    
    # get emulator hash
    emulator_hash = emulator.to_hash

    # existing
    full_design = project.design
    full_run = project.run

    # select design and run
    indices = self.emulator_project.emulator.validation_indices
    self.design = self.create_design(simulator_specification: spec, size: self.design_size)
    full_design.design_values.each do |dv|
      self.design.design_values.create(input: dv.input, points: indices.collect {|i| dv.points[i] })
    end

    self.run = self.create_run(simulator_specification: spec, design: self.design, size: self.design_size)
    selected_run = full_run.run_values.where(output_id: emulator.output.id).first
    self.run.run_values.create(output: emulator.output, points: indices.collect {|i| selected_run.points[i] })
    
    # request hash
    { type: 'ValidationRequest',
      emulator: emulator_hash,
      design: self.design.to_hash,
      evaluationResult: self.run.to_hash }
  end
  
  def handle(response)
    # get project and output specifications
    project = self.emulator_project
    outputs = project.simulator_specification.outputs
    
    # parse result
    result = response['result']
    self.emulator_time = result['emulatorTime']
    result['outputResults'].each do |set|
      output = outputs.where(:name => set['outputIdentifier']).first
      self.validation_values.create(output: output, z_scores: set['zScores'], simulator: set['simulator'],
        emulator_mean: set['emulatorMean'], emulator_variance: set['emulatorVariance'], rmse: set['rmse'])
    end
  end
  
end
