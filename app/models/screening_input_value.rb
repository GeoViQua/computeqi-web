class ScreeningInputValue
  include Mongoid::Document
  
  belongs_to :input
  belongs_to :screening_value
  
  field :mean_ee, type: Float
  field :mean_star_ee, type: Float
  field :std_ee, type: Float
  field :ee, type: Array
  
  def to_hash
    { inputIdentifier: self.input.name,
      meanEE: self.mean_ee,
      meanStarEE: self.mean_star_ee,
      stdEE: self.std_ee,
      ee: self.ee }
  end
end