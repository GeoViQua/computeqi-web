class RunValue
  include Mongoid::Document
  
  belongs_to :run
  belongs_to :output
  
  field :points, type: Array
  
  def to_hash
    { outputIdentifier: self.output.name, results: self.points }
  end
end
