class InputScreening
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :emulator_project
  has_many :screening_values
  
  field :num_trajectories, type: Integer, default: 5
  field :discretisation_level, type: Integer, default: 10
  field :delta_p, type: Integer, default: 1
  
  def to_hash
    self.screening_values.collect {|value| value.to_hash }
  end
  
  def generate
    # get project and spec
    project = self.emulator_project
    spec = project.simulator_specification
    
    # request hash
    { type: 'ScreeningRequest',
      serviceURL: spec.service_url,
      processIdentifier: spec.process_name,
      inputs: spec.inputs.collect {|input| input.to_hash },
      outputs: spec.outputs.collect {|output| output.to_hash },
      numTrajectories: self.num_trajectories,
      discretisationLevel: self.discretisation_level,
      deltaP: self.delta_p }
  end
  
  def handle(response)
    # get input and output specifications
    project = self.emulator_project
    spec = project.simulator_specification
    inputs = spec.inputs
    outputs = spec.outputs
    
    # parse run
    response['results'].each do |set|
      output = outputs.where(:name => set['outputIdentifier']).first
      screening_value = self.screening_values.create(output: output)
      set['inputResults'].each do |input_set|
        input = inputs.where(:name => input_set['inputIdentifier']).first
        screening_value.screening_input_values.create(input: input, mean_ee: input_set['meanEE'], mean_star_ee: input_set['meanStarEE'], std_ee: input_set['stdEE'], ee: input_set['ee'])
      end
    end
  end

  def remove_input(name)
    screening_values.each do |value|
      screening_value.screening_input_values.each do |input_value|
        if input_value.input.name == name
          input_value.destroy
        end
      end
    end
  end
end
