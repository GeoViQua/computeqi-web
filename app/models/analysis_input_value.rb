class AnalysisInputValue
  include Mongoid::Document

  belongs_to :input
  belongs_to :analysis_value
  
  # sobol fields
  field :first_original, type: Float
  field :first_bias, type: Float
  field :first_std_error, type: Float
  field :first_min_ci, type: Float
  field :first_max_ci, type: Float
  field :total_original, type: Float
  field :total_bias, type: Float
  field :total_std_error, type: Float
  field :total_min_ci, type: Float
  field :total_max_ci, type: Float

  # fast fields
  field :main_effect, type: Float
  field :interactions, type: Float
  field :variance, type: Float
  
  def to_hash
    hash = { inputIdentifier: self.input.name }

    if self.first_original
      hash.merge!({
        firstOriginal: self.first_original,
        firstBias: self.first_bias,
        firstStdError: self.first_std_error,
        firstMinCI: self.first_min_ci,
        firstMaxCI: self.first_max_ci,
        totalOriginal: self.total_original,
        totalBias: self.total_bias,
        totalStdError: self.total_std_error,
        totalMinCI: self.total_min_ci,
        totalMaxCI: self.total_max_ci
      })
    else
      hash.merge!({
        mainEffect: self.main_effect,
        interactions: self.interactions,
        variance: self.variance
      })
    end
  end
end
