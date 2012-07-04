class ValidationValue
  include Mongoid::Document
  
  belongs_to :validation
  belongs_to :output
  
  field :z_scores, type: Array
  field :simulator, type: Array
  field :emulator_mean, type: Array
  field :emulator_variance, type: Array
  field :rmse, type: Float
  
  def to_hash
    { outputIdentifier: self.output.name,
      zScores: self.z_scores,
      simulator: self.simulator,
      emulatorMean: self.emulator_mean,
      emulatorVariance: self.emulator_variance,
      rmse: self.rmse }
  end
end
