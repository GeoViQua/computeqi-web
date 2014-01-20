class Validation
  include Mongoid::Document
  include Remote::Remotable

  belongs_to :validatable, polymorphic: true

  field :name, type: String

  # only used for non-emulator
  field :reference, type: Array
  field :observed, type: Object

  field :missing_value_code, type: Float, default: -9900.0

  # compute quality indicators
  field :learning_percentage, type: Integer, default: 80
  field :quality_indicators, type: Hash

  field :mean_bias, type: Float
  field :mean_mae, type: Float
  field :mean_rmse, type: Float
  field :mean_correlation, type: Float
  field :brier_score, type: Float

  field :vs_observed_mean_plot_data, type: Hash
  field :standard_score_plot_data, type: Hash
  field :mean_residual_histogram_data, type: Hash
  field :mean_residual_qq_plot_data, type: Hash
  field :rank_histogram_data, type: Hash
  field :reliability_diagram_data, type: Hash
  field :coverage_plot_data, type: Hash

  def calculate_defaults
    project = self.validatable
  end

  def to_hash
    { meanBias: self.mean_bias,
      meanMAE: self.mean_mae,
      meanRMSE: self.mean_rmse,
      meanCorrelation: self.mean_correlation,
      brierScore: self.brier_score,
      vsObservedMeanPlotData: self.vs_observed_mean_plot_data,
      standardScorePlotData: self.standard_score_plot_data,
      meanResidualHistogramData: self.mean_residual_histogram_data,
      meanResidualQQPlotData: self.mean_residual_qq_plot_data,
      rankHistogramData: self.rank_histogram_data,
      reliabilityDiagramData: self.reliability_diagram_data,
      coveragePlotData: self.coverage_plot_data,
      learningPercentage: self.learning_percentage,
      qualityIndicators: self.quality_indicators }
  end
  
  def generate
    if self.observed.first.class == Array
      observed_obj = self.observed.map {|value| { members: value} }
    else
      observed_obj = self.observed
    end

    {
      type: 'QualityIndicatorsRequest',
      reference: self.reference,
      observed: observed_obj,
      learningPercentage: self.learning_percentage,
      metrics: {
        distribution: Array["normal"],
        statistics: Array["correlation", "mean", "stdev", "skewness", "kurtosis", "median", "quantiles"]
      }
    }
  end

  def observed_size
    self.observed.size
  end

  def validation_size
    (observed_size - ((self.learning_percentage.to_f / 100) * observed_size)).round
  end

  def handle(response)
    self.mean_bias = response['meanBias']
    self.mean_mae = response['meanMAE']
    self.mean_rmse = response['meanRMSE']
    self.mean_correlation = response['meanCorrelation']
    self.brier_score = response['brierScore']
    self.vs_observed_mean_plot_data = response['vsObservedMeanPlotData']
    self.standard_score_plot_data = response['standardScorePlotData']
    self.mean_residual_histogram_data = response['meanResidualHistogramData']
    self.mean_residual_qq_plot_data = response['meanResidualQQPlotData']
    self.rank_histogram_data = response['rankHistogramData']
    self.reliability_diagram_data = response['reliabilityDiagramData']
    self.coverage_plot_data = response['coveragePlotData']
    self.quality_indicators = response['qualityIndicatorsResult']['struct']
  end
end