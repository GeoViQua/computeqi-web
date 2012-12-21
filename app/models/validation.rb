class Validation
  include Mongoid::Document
  include Remote::Remotable

  belongs_to :validatable, polymorphic: true

  field :name, type: String

  # only used for emulator
  field :design_size, type: Integer
  has_one :design, as: :designable
  has_one :run, as: :runnable

  # only used for non-emulator
  field :observed, type: Array
  field :predicted, type: Object

  field :mean_bias, type: Float
  field :mean_mae, type: Float
  field :mean_rmse, type: Float
  field :mean_correlation, type: Float
  field :median_bias, type: Float
  field :median_mae, type: Float
  field :median_rmse, type: Float
  field :median_correlation, type: Float
  field :brier_score, type: Float
  field :crps, type: Float
  field :crps_reliability, type: Float
  field :crps_resolution, type: Float
  field :crps_uncertainty, type: Float
  field :ign_score, type: Float
  field :ign_reliability, type: Float
  field :ign_resolution, type: Float
  field :ign_uncertainty, type: Float

  field :vs_predicted_mean_plot_data, type: Hash
  field :vs_predicted_median_plot_data, type: Hash
  field :standard_score_plot_data, type: Hash
  field :mean_residual_histogram_data, type: Hash
  field :mean_residual_qq_plot_data, type: Hash
  field :median_residual_histogram_data, type: Hash
  field :median_residual_qq_plot_data, type: Hash
  field :rank_histogram_data, type: Hash
  field :reliability_diagram_data, type: Hash
  field :coverage_plot_data, type: Hash

  def calculate_defaults
    project = self.validatable
    if project.class == EmulatorProject
      self.design_size = project.emulator.validation_indices.size
    end
  end

  def to_hash
    { meanBias: self.mean_bias,
      meanMAE: self.mean_mae,
      meanRMSE: self.mean_rmse,
      meanCorrelation: self.mean_correlation,
      medianBias: self.median_bias,
      medianMAE: self.median_mae,
      medianRMSE: self.median_rmse,
      medianCorrelation: self.median_correlation,
      brierScore: self.brier_score,
      crps: self.crps,
      crpsReliability: self.crps_reliability,
      crpsResolution: self.crps_resolution,
      crpsUncertainty: self.crps_uncertainty,
      ignScore: self.ign_score,
      ignReliability: self.ign_reliability,
      ignResolution: self.ign_resolution,
      ignUncertainty: self.ign_uncertainty,
      vsPredictedMeanPlotData: self.vs_predicted_mean_plot_data,
      vsPredictedMedianPlotData: self.vs_predicted_median_plot_data,
      standardScorePlotData: self.standard_score_plot_data,
      meanResidualHistogramData: self.mean_residual_histogram_data,
      meanResidualQQPlotData: self.mean_residual_qq_plot_data,
      medianResidualHistogramData: self.median_residual_histogram_data,
      medianResidualQQPlotData: self.median_residual_qq_plot_data,
      rankHistogramData: self.rank_histogram_data,
      reliabilityDiagramData: self.reliability_diagram_data,
      coveragePlotData: self.coverage_plot_data }
  end
  
  def generate
    # get project
    project = self.validatable

    if project.class == EmulatorProject
      # get spec and emulator
      spec = project.simulator_specification
      emulator = project.emulator
    
      # get emulator hash
      emulator_hash = emulator.to_hash

      # existing
      full_design = project.design
      full_run = project.run

      # get indices to use for validation
      # this should potentially be a random sample
      indices = project.emulator.validation_indices[0...self.design_size]

      # build design and runs
      self.design = self.create_design(simulator_specification: spec, size: self.design_size)
      full_design.design_values.each do |dv|
        self.design.design_values.create(input: dv.input, points: indices.collect {|i| dv.points[i] })
      end

      self.run = self.create_run(simulator_specification: spec, design: self.design, size: self.design_size)
      selected_run = full_run.run_values.where(output_id: emulator.output.id).first
      self.run.run_values.create(output: emulator.output, points: indices.collect {|i| selected_run.points[i] })

      { type: 'ValidationRequest',
        emulator: emulator_hash,
        design: self.design.to_hash,
        evaluationResult: self.run.to_hash }
    else
      # non-emulator
      if self.predicted.first.class == Array
        predicted_obj = self.predicted.map {|value| { members: value} }
      else
        predicted_obj = self.predicted
      end

      { type: 'ValidationRequest',
        observed: self.observed,
        predicted: predicted_obj }
    end
  end

  def predicted_size
    if self.validatable.class == EmulatorProject
      self.design.size
    else
      self.predicted.size
    end
  end

  def handle(response)
    self.mean_bias = response['meanBias']
    self.mean_mae = response['meanMAE']
    self.mean_rmse = response['meanRMSE']
    self.mean_correlation = response['meanCorrelation']
    self.median_bias = response['medianBias']
    self.median_mae = response['medianMAE']
    self.median_rmse = response['medianRMSE']
    self.median_correlation = response['medianCorrelation']
    self.brier_score = response['brierScore']
    self.crps = response['crps']
    self.crps_reliability = response['crpsReliability']
    self.crps_resolution = response['crpsResolution']
    self.crps_uncertainty = response['crpsUncertainty']
    self.ign_score = response['ignScore']
    self.ign_reliability = response['ignReliability']
    self.ign_resolution = response['ignResolution']
    self.ign_uncertainty = response['ignUncertainty']
    self.vs_predicted_mean_plot_data = response['vsPredictedMeanPlotData']
    self.vs_predicted_median_plot_data = response['vsPredictedMedianPlotData']
    self.standard_score_plot_data = response['standardScorePlotData']
    self.mean_residual_histogram_data = response['meanResidualHistogramData']
    self.mean_residual_qq_plot_data = response['meanResidualQQPlotData']
    self.median_residual_histogram_data = response['medianResidualHistogramData']
    self.median_residual_qq_plot_data = response['medianResidualQQPlotData']
    self.rank_histogram_data = response['rankHistogramData']
    self.reliability_diagram_data = response['reliabilityDiagramData']
    self.coverage_plot_data = response['coveragePlotData']
  end
end