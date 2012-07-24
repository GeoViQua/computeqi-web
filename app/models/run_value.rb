class RunValue
  include Mongoid::Document
  
  belongs_to :run
  belongs_to :output
  
  field :points, type: Array
  field :mean, type: Float
  field :std_dev, type: Float
  
  def to_hash
    hash = { outputIdentifier: self.output.name, results: self.points }
    hash.merge({ mean: self.mean, stdDev: self.std_dev }) if self.mean
  end
end
