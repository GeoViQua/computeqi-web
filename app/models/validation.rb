class Validation
  include Mongoid::Document
  include Remote::Remotable

  belongs_to :validation_project

  field :name, type: String
  field :observed, type: Array
  field :predicted, type: Object

  field :rmse, type: Float

  field :standard_score_data, type: Hash
  field :mean_residual_data, type: Hash
  field :median_residual_data, type: Hash
  field :reliability_data, type: Hash

  def to_hash
    { observed: self.observed,
      predicted: self.predicted,
      rmse: self.rmse,
      standardScoreData: self.standard_score_data,
      meanResidualData: self.mean_residual_data,
      medianResidualData: self.median_residual_data,
      reliabilityData: self.reliability_data }
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
    self.standard_score_data = response['standardScoreData']
    self.mean_residual_data = response['meanResidualData']
    self.median_residual_data = response['medianResidualData']
    self.reliability_data = response['reliabilityData']
  end
end