class SimulatorSpecification
  include Mongoid::Document
  
  belongs_to :specable, polymorphic: true
  
  field :service_url, type: String
  field :process_name, type: String
  field :process_description, type: String
  
  has_many :inputs, autosave: true, dependent: :destroy
  has_many :outputs, autosave: true, dependent: :destroy
  
  has_many :designs
  has_many :runs
  
  accepts_nested_attributes_for :inputs, :outputs
  
  def complete?
    !self.inputs.select {|input| input.set? }.empty?
  end

  def has_input_samples?
    Input.where(:simulator_specification_id => self.id).and(:sample_values.ne => nil).exists?
  end
  
end
