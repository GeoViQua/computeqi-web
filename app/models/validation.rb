class Validation
  include Mongoid::Document
  include Remote::Remotable

  belongs_to :validation_project

  field :name, type: String
  field :observed, type: Array
  field :predicted, type: Object

  field :rmse, type: Float
  field :standard_scores, type: Array
  
  def generate
    { type: 'ValidationRequest',
      observed: self.observed,
      predicted: self.predicted }
  end

  def handle(response)
    self.rmse = response['rmse']
    self.standard_scores = response['standardScores']
  end
end