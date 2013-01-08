class Input
  include Mongoid::Document
  
  field :name, type: String
  field :description, type: String
  field :type, type: String, default: "Numeric"
  field :value_type, type: String, default: "variable"
  field :uom, type: String
  
  field :fixed_value, type: Float
  field :minimum_value, type: Float
  field :maximum_value, type: Float
  field :sample_values, type: Array
  
  belongs_to :simulator_specification
  
  has_one :design_value
  has_many :screening_input_values
  has_many :analysis_input_values

  validates_inclusion_of :type, in: ["Numeric"]
  validates_inclusion_of :value_type, in: ["fixed", "variable", "samples"]  
  
  validate :fixed_variable_or_samples
  validates_numericality_of :fixed_value, if: :fixed?
  validates_numericality_of :minimum_value, if: :variable?
  validates_numericality_of :maximum_value, if: :variable?

  before_save :nil_blanks
  
  def fixed_variable_or_samples
    if fixed_value.nil? and (minimum_value.nil? or maximum_value.nil?)
      errors[:base] << "The input can either have a fixed value, or a range."
    end
  end
  
  def fixed?
    value_type == 'fixed'
  end
  
  def variable?
    value_type == 'variable'
  end

  def samples?
    value_type == 'samples'
  end
  
  def set?
    fixed_value != nil or (minimum_value != nil and maximum_value != nil) or samples != nil
  end
  
  def to_hash
    # calculate min/max from samples?
    hash = if self.variable?
      { identifier: self.name, range: { min: self.minimum_value, max: self.maximum_value } }
    else
      { identifier: self.name, value: self.fixed_value }
    end

    d = {
      dataType: 'Numeric',
      encodingType: 'double'
    }
    if self.description
      d[:detail] = self.description
    end
    if self.uom
      d[:uom] = self.uom
    end
    hash[:description] = d
    hash
  end

  private

  def nil_blanks
    self.description = nil if self.description and self.description.empty?
    self.uom = nil if self.uom and self.uom.empty?
  end
  
end
