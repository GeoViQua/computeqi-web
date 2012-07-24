class DesignValue
  include Mongoid::Document
  
  belongs_to :design
  belongs_to :input
  
  field :points, type: Array
  field :mean, type: Float
  field :std_dev, type: Float
  
  def to_hash
    hash = { inputIdentifier: self.input.name,
      points: self.points }
    hash = hash.merge({ mean: self.mean, stdDev: self.std_dev }) if self.mean
    hash
  end
end
