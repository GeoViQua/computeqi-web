class DesignValue
  include Mongoid::Document
  
  belongs_to :design
  belongs_to :input
  
  field :points, type: Array
  
  def to_hash
    { inputIdentifier: self.input.name,
      points: self.points }
  end
end
