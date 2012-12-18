class Validation
  include Mongoid::Document
  include Remote::Remotable

  belongs_to :validation_project

  field :name, type: String
  field :observed, type: Array
  field :predicted, type: Object

  field :rmse, type: Float

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

  def to_hash
    { observed: self.observed,
      predicted: self.predicted,
      rmse: self.rmse,
      vsPredictedMeanPlotData: self.vs_predicted_mean_plot_data,
      vsPredictedMedianPlotData: self.vs_predicted_median_plot_data,
      standardScorePlotData: self.standard_score_plot_data,
      meanResidualHistogramData: self.mean_residual_histogram_data,
      meanResidualQQPlotData: self.mean_residual_qq_plot_data,
      medianResidualHistogramData: self.median_residual_histogram_data,
      medianResidualQQPlotData: self.median_residual_qq_plot_data,
      rankHistogramData: self.rank_histogram_data,
      reliabilityDiagramData: self.reliability_diagram_data,
      coveragePlotData: self.coveragePlotData }
  end
  
  def generate
    if self.predicted.first.class == Array
      predicted_obj = self.predicted.map {|value| { members: value} }
    else
      predicted_obj = self.predicted
    end

    { type: 'ValidationRequest',
      observed: self.observed,
      predicted: predicted_obj }
  end

  def handle(response)
    self.rmse = response['rmse']
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