class Output
  include Mongoid::Document
  
  field :name, type: String
  field :description, type: String
  field :type, type: String, default: "Numeric"
  
  belongs_to :simulator_specification
  
  has_one :run_value
  has_one :screening_value
  has_one :emulator
  has_one :validation_value
  has_one :analysis_value
  
  def to_hash
    { identifier: self.name }
  end
  
  def to_s
    self.name
  end
end
