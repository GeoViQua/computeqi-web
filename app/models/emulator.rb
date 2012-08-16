class Emulator
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :emulator_project
  belongs_to :output
  
  field :training_size, type: Integer
  field :training_indices, type: Array
  field :validation_indices, type: Array
  field :mean_function, type: String, default: "linear"
  field :cov_function, type: String, default: "matern"
  field :length_scale, type: Float
  field :nugget_variance, type: Float, default: 0.0001
  field :nugget_variance_enabled, type: Boolean, default: false
  field :normalisation, type: Boolean, default: true

  # subset used to train
  has_one :design, as: :designable
  has_one :run, as: :runnable

  # validation
  # using both presence_of and numericality_of so you don't get "is not a number"
  # for a blank field
  validates_presence_of :training_size
  validates_numericality_of :training_size

  validates_inclusion_of :mean_function, in: ["zero", "constant", "linear", "quadratic"]
  validates_inclusion_of :cov_function, in: ["matern", "squared_exponential"]  

  validates_presence_of :length_scale
  validates_numericality_of :length_scale

  validates_presence_of :nugget_variance, if: Proc.new { self.nugget_variance_enabled }
  validates_numericality_of :nugget_variance, if: Proc.new { self.nugget_variance_enabled }

  def calculate_defaults
    self.training_size = (self.emulator_project.design.size * 0.33).floor
  end
  
  def to_hash
    # get project and spec
    project = self.emulator_project
    spec = project.simulator_specification
    
    # collect inputs
    inputs = []
    spec.inputs.each do |input|
      inputs << input.to_hash
    end
    
    # collect outputs
    outputs = [ output.to_hash ]

    # build hash
    hash = { inputs: inputs,
      outputs: outputs,
      design: self.design.to_hash,
      evaluationResult: self.run.to_hash,
      meanFunction: self.mean_function,
      covarianceFunction: self.cov_function,
      lengthScale: self.length_scale }

    # add nugget
    if self.nugget_variance_enabled
      hash = hash.merge({ nuggetVariance: self.nugget_variance })
    end

    # return
    hash
  end

  def to_matlab
    # this isn't too nice - ties to gpml
    # get meanf
    meanf = if self.mean_function == "zero"
      meanf_params = []
      ""
    else
      if self.mean_function == "constant"
        meanf_params = [0]
      elsif self.mean_function == "linear"
        meanf_params = [1]
      else
        meanf_params = [2]
      end
      "mean_poly"
    end

    # get covf
    covf = if self.cov_function == "squared_exponential"
      "'covSEiso'"
    else
      "'covMatern3iso'"
    end

    # add nugget
    covf_params = [self.length_scale]
    if self.nugget_variance_enabled
      covf = "{'covSum',{#{covf},'covNoise'}}"
      covf_params << self.nugget_variance
    end

    "struct('trn', struct('in', #{self.design.to_matlab}, 'out', #{self.run.to_matlab}), 'meanf', struct('name', '#{meanf}', 'par', #{meanf_params}), 'covf', struct('name', #{covf}, 'par', log(#{covf_params}')))"
  end
  
  def generate
    # get emulator project and spec
    project = self.emulator_project
    spec = project.simulator_specification

    # existing
    full_design = project.design
    full_run = project.run

    # generate random indices
    # http://synthesis.sbecker.net/articles/2007/06/05/random-permutation-in-ruby
    p = [*0...full_design.size]
    1.upto(p.length - 1) do |i|
      j = rand(i + 1)
      p[i], p[j] = p[j], p[i]
    end
    self.training_indices = p.slice(0, self.training_size)
    self.validation_indices = p.slice(self.training_size, full_design.size - self.training_size)

    # create sampled design
    self.design = self.create_design(simulator_specification: spec, size: self.training_size)
    full_design.design_values.each do |dv|
      self.design.design_values.create(input: dv.input, points: self.training_indices.collect {|i| dv.points[i] })
    end

    # create sampled run
    self.run = self.create_run(simulator_specification: spec, design: self.design, size: self.training_size)
    selected_run = full_run.run_values.where(output_id: self.output.id).first
    self.run.run_values.create(output: self.output, points: self.training_indices.collect {|i| selected_run.points[i] })
    
    # request hash
    { type: 'LearningRequest',
      design: self.design.to_hash,
      evaluationResult: self.run.to_hash,
      selectedOutputIdentifier: self.output.name,
      meanFunction: self.mean_function,
      covarianceFunction: self.cov_function,
      lengthScale: self.length_scale,
      nuggetVariance: self.nugget_variance_enabled ? self.nugget_variance : nil,
      normalisation: self.normalisation
    }
  end
  
  def handle(response)
    # get project and specifications
    project = self.emulator_project
    spec = project.simulator_specification
    inputs = spec.inputs
    outputs = spec.outputs
    
    # parse result
    result = response['result']
    # skipping predictedMean, predictedVariance (arrays)

    self.design = self.create_design(simulator_specification: spec, size: result['design']['size'])
    result['design']['map'].each do |set|
      input = inputs.where(:name => set['inputIdentifier']).first
      value = design.design_values.build(input: input, points: set['points'])
      if set.has_key?('mean')
        value.mean = set['mean']
        value.std_dev = set['stdDev']
      end
      value.save
    end
    
    self.run = self.create_run(simulator_specification: spec, design: design, size: design.size)
    result['evaluationResult'].each do |set|
      output = outputs.where(:name => set['outputIdentifier']).first
      value = run.run_values.build(output: output, points: set['results'])
      if set.has_key?('mean')
        value.mean = set['mean']
        value.std_dev = set['stdDev']
      end
      value.save
    end

    self.length_scale = result['lengthScale']
    self.nugget_variance = result['nuggetVariance'] if self.nugget_variance_enabled
  end
  
end
