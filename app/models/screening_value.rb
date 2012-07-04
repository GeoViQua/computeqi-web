class ScreeningValue
  include Mongoid::Document
  
  belongs_to :input_screening
  belongs_to :output
  has_many :screening_input_values
  
  def to_r
    "r"
  end
  
  def to_matlab
    "matlab"
  end
  
  def to_hash
    { outputIdentifier: self.output.name,
      inputResults: self.screening_input_values.collect {|value| value.to_hash } }
  end
end
