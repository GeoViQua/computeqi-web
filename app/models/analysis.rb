class Analysis
  include Mongoid::Document
  include Remote::Remotable

  # relationships
  has_many :analysis_values
  belongs_to :sensitivity_project

  # fields
  field :design_size, type: Integer
  field :analysis_method, type: String, default: "sobol"

  # sobol parameters
  field :num_boot, type: Integer, default: 100
  field :conf_level, type: Float, default: 0.95

  # validation
  validates_presence_of :design_size
  validates_numericality_of :design_size, greater_than: 0
  validates_presence_of :analysis_method
  validates_inclusion_of :analysis_method, in: ["sobol", "fast"]

  # validation: sobol parameters
  validates_presence_of :num_boot, if: :sobol?
  validates_numericality_of :num_boot, greater_than_or_equal_to: 2, if: :sobol?
  validates_presence_of :conf_level, if: :sobol?
  validates_numericality_of :conf_level, if: :sobol?

  def sobol?
    self.analysis_method == "sobol"
  end

  def fast?
    self.analysis_method == "fast"
  end

  def calculate_defaults
    parent = self.sensitivity_project
    if parent.uses_emulator?
      parent = parent.emulator_project
    end
    self.design_size = parent.simulator_specification.inputs.count * 10
  end

  def to_hash
    { outputResults: self.analysis_values.collect {|value| value.to_hash } }
  end
  
  def generate
    # get project and spec
    project = self.sensitivity_project

    # request hash
    request_hash = { 
      type: 'SensitivityRequest',
      plot: true,
      designSize: self.design_size,
      method: self.analysis_method
    }

    # add parameters
    if self.analysis_method == "sobol"
      request_hash.merge!({
        numBoot: self.num_boot,
        confidenceLevel: self.conf_level
      })
    end

    # check if simulator or emulator
    emulator_project = project.emulator_project
    if emulator_project.nil?
      # use simulator
      spec = project.simulator_specification
      request_hash = request_hash.update({
        serviceURL: spec.service_url,
        processIdentifier: spec.process_name,
        inputs: spec.inputs.collect {|input| input.to_hash },
        outputs: spec.outputs.collect {|output| output.to_hash }
      })
    else
      # use emulator
      emulator_hash = emulator_project.emulator.to_hash
      request_hash = request_hash.update({
        emulator: emulator_hash
      })
    end

    # return
    request_hash
  end
  
  def handle(response)
    # get spec
    project = self.sensitivity_project
    spec = nil
    if project.emulator_project.nil?
      spec = project.simulator_specification
    else
      spec = project.emulator_project.simulator_specification
    end
    inputs = spec.inputs
    outputs = spec.outputs
    
    # parse result
    response['results'].each do |result|
      output = outputs.where(:name => result['outputIdentifier']).first
      value = self.analysis_values.create(output: output, remote_plot_url: result['plot'])
      result['inputResults'].each do |input_result|
        input = inputs.where(:name => input_result['inputIdentifier']).first
        
        if self.sobol?
          value.analysis_input_values.create(
            input: input,
            first_original: input_result['firstOriginal'],
            first_bias: input_result['firstBias'],
            first_std_error: input_result['firstStdError'],
            first_min_ci: input_result['firstMinCI'],
            first_max_ci: input_result['firstMaxCI'],
            total_original: input_result['totalOriginal'],
            total_bias: input_result['totalBias'],
            total_std_error: input_result['totalStdError'],
            total_min_ci: input_result['totalMinCI'],
            total_max_ci: input_result['totalMaxCI']
          )
        else
          value.analysis_input_values.create(
            input: input,
            d1: input_result['d1'],
            dt: input_result['dt'],
            v: input_result['v']
          )
        end
      end
    end
  end
end
