class Validation
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :emulator_project
  has_many :validation_values
  
  field :design_size, type: Integer
  field :emulator_time, type: Integer
  field :simulator_time, type: Integer
  
  def to_hash
    { emulatorTime: self.emulator_time,
      simulatorTime: self.simulator_time,
      outputResults: self.validation_values.collect {|value| value.to_hash } }
  end
  
  def generate
    # get project and spec
    project = self.emulator_project
    spec = project.simulator_specification
    
    # get emulator hash
    emulator_hash = project.emulator.to_hash
    
    # request hash
    { type: 'ValidationRequest',
      serviceURL: spec.service_url,
      processIdentifier: spec.process_name,
      emulator: emulator_hash,
      inputs: emulator_hash[:inputs],
      outputs: emulator_hash[:outputs],
      designSize: self.design_size }
  end
  
  def handle(response)
    # get project and output specifications
    project = self.emulator_project
    outputs = project.simulator_specification.outputs
    
    # parse result
    result = response['result']
    self.emulator_time = result['emulatorTime']
    self.simulator_time = result['processTime']
    result['outputResults'].each do |set|
      output = outputs.where(:name => set['outputIdentifier']).first
      self.validation_values.create(output: output, z_scores: set['zScores'], simulator: set['simulator'],
        emulator_mean: set['emulatorMean'], emulator_variance: set['emulatorVariance'], rmse: set['rmse'])
    end
  end
  
end
