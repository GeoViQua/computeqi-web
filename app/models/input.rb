class Input
  include Mongoid::Document
  
  field :name, type: String
  field :description, type: String
  field :type, type: String, default: "Numeric"
  
  field :fixed_value, type: Float
  field :minimum_value, type: Float
  field :maximum_value, type: Float
  
  belongs_to :simulator_specification
  
  has_one :design_value
  has_many :screening_input_values
  has_many :analysis_input_values
  
  validate :fixed_or_variable
  validates_numericality_of :fixed_value, if: :fixed?
  validates_numericality_of :minimum_value, if: :variable?
  validates_numericality_of :maximum_value, if: :variable?
  
  def fixed_or_variable
    if fixed_value != nil and (minimum_value != nil or maximum_value != nil)
      errors.add(:fixed_value, "The input can either have a fixed value, or a range.")
    end
  end
  
  def fixed?
    fixed_value != nil
  end
  
  def variable?
    fixed_value == nil
  end
  
  def set?
    fixed_value != nil or (minimum_value != nil and maximum_value != nil)
  end
  
  def to_hash
    if self.variable?
      { identifier: self.name, range: { min: self.minimum_value, max: self.maximum_value } }
    else
      { identifier: self.name, value: self.fixed_value }
    end
  end
  
end
