class Validation
  include Mongoid::Document
  include Remote::Remotable

  belongs_to :validation_project

  field :name, type: String
  field :observed, type: Array
  field :predicted, type: Object

  field :rmse, type: Float
  field :standard_scores, type: Array
  field :mean_residual_data, type: Object
  field :median_residual_data, type: Object
  field :reliability_data, type: Object

  def to_hash
    { observed: self.observed,
      predicted: self.predicted,
      rmse: self.rmse,
      standardScores: self.standard_scores,
      meanResidualHistogram: self.mean_residual_data,
      medianResidualHistogram: self.median_residual_data,
      reliabilityDiagram: self.reliability_data }
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
    self.standard_scores = response['standardScores']
    self.mean_residual_data = response['meanResidualHistogram']
    self.median_residual_data = response['medianResidualHistogram']
    self.reliability_data = response['reliabilityDiagram']
  end
end