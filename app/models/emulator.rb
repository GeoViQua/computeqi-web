class Emulator
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :emulator_project
  belongs_to :output
  
  field :training_size, type: Integer
  field :training_indices, type: Array
  field :mean_function, type: String, default: "constant"
  field :cov_function, type: String, default: "squared_exponential"
  field :length_scale, type: Float
  field :process_variance, type: Float
  field :nugget_variance, type: Float, default: 0.0001
  field :nugget_variance_enabled, type: Boolean, default: false
  field :normalisation, type: Boolean, default: true
  field :design_mean, type: Array
  field :design_std_dev, type: Array
  field :run_mean, type: Float
  field :run_std_dev, type: Float

  # subset used to train
  has_one :design, as: :designable
  has_one :run, as: :runnable

  # validation
  # using both presence_of and numericality_of so you don't get "is not a number"
  # for a blank field
  validates_presence_of :training_size
  validates_numericality_of :training_size

  validates_inclusion_of :mean_function, in: ["zero", "constant", "linear", "quadratic"]
  validates_inclusion_of :cov_function, in: ["squared_exponential", "matern"]  

  validates_presence_of :length_scale
  validates_numericality_of :length_scale

  validates_presence_of :process_variance
  validates_numericality_of :process_variance

  validates_presence_of :nugget_variance, if: Proc.new { self.nugget_variance_enabled }
  validates_numericality_of :nugget_variance, if: Proc.new { self.nugget_variance_enabled }
  
  def to_hash
    # get project and spec
    project = self.emulator_project
    spec = project.simulator_specification
    
    # collect inputs
    inputs = []
    input_descriptions = []
    spec.inputs.each do |input|
      inputs << input.to_hash
      input_descriptions << { identifier: input.name, dataType: 'Numeric', encodingType: 'double' }
    end
    
    # collect outputs
    outputs = []
    output_descriptions = []
    # spec.outputs.each do |output|
      outputs << output.to_hash
      output_descriptions << { identifier: output.name, dataType: 'Numeric', encodingType: 'double' }
    # end
    
    # build hash
    hash = { inputs: inputs,
      outputs: outputs,
      inputDescriptions: input_descriptions,
      outputDescriptions: output_descriptions,
      trainingDesign: self.design.to_hash,
      trainingEvaluationResult: self.run.to_hash,
      meanFunction: self.mean_function,
      covarianceFunction: self.cov_function,
      lengthScale: self.length_scale,
      processVariance: self.process_variance,
      nuggetVariance: self.nugget_variance_enabled ? self.nugget_variance : nil }

    # add normalisation parameters
    if self.normalisation
      hash[:designMean] = self.design_mean
      hash[:designStdDev] = self.design_std_dev
      hash[:evaluationResultMean] = self.run_mean
      hash[:evaluationResultStdDev] = self.run_std_dev
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
    covf_params = [self.length_scale, Math.sqrt(self.process_variance)]
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

    # # existing
    # full_design = project.design
    # full_run = project.run

    # # generate random indices
    # p = [*0...full_design.size]
    # self.training_indices = self.training_size.times.collect { p.sample }

    # # create sampled design
    # self.design = self.create_design(simulator_specification: spec, size: self.training_size)
    # full_design.design_values.each do |dv|
    #   self.design.design_values.create(input: dv.input, points: self.training_indices.collect {|i| dv.points[i] })
    # end

    # # create sampled run
    # self.run = self.create_run(simulator_specification: spec, design: self.design, size: self.training_size)
    # full_run.run_values.each do |rv|
    #   self.run.run_values.create(output: rv.output, points: self.training_indices.collect {|i| rv.points[i] })
    # end
    
    # request hash
    # { type: 'LearningRequest',
    #   trainingDesign: self.design.to_hash,
    #   trainingEvaluationResult: self.run.to_hash,
    #   selectedOutputIdentifier: self.output.name,
    #   meanFunction: self.mean_function,
    #   covarianceFunction: self.cov_function,
    #   lengthScale: self.length_scale,
    #   processVariance: self.process_variance,
    #   nuggetVariance: self.nugget_variance_enabled ? self.nugget_variance : nil,
    #   normalisation: self.normalisation
    # }

     # request hash
    { type: 'LearningRequest',
      design: project.design.to_hash,
      evaluationResult: project.run.to_hash,
      selectedOutputIdentifier: self.output.name,
      trainingSetSize: self.training_size,
      meanFunction: self.mean_function,
      covarianceFunction: self.cov_function,
      lengthScale: self.length_scale,
      processVariance: self.process_variance,
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

    design = self.create_design(simulator_specification: spec, size: result['trainingDesign']['size'])
    result['trainingDesign']['map'].each do |set|
      input = inputs.where(:name => set['inputIdentifier']).first
      design.design_values.create(input: input, points: set['points'])
    end
    
    run = self.create_run(simulator_specification: spec, design: design, size: design.size)
    result['trainingEvaluationResult'].each do |set|
      output = outputs.where(:name => set['outputIdentifier']).first
      run.run_values.create(output: output, points: set['results'])
    end

    self.length_scale = result['lengthScale']
    self.process_variance = result['processVariance']

    if self.normalisation
      self.design_mean = result['designMean']
      self.design_std_dev = result['designStdDev']
      self.run_mean = result['evaluationResultMean']
      self.run_std_dev = result['evaluationResultStdDev']
    end
  end
  
end
