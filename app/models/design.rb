class Design
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :simulator_specification
  belongs_to :designable, polymorphic: true
  
  has_many :design_values
  has_one :run
  
  field :size, type: Integer
  field :sampling_method, type: String, default: "lhs"
  
  validates_inclusion_of :sampling_method, in: ["lhs"]

  def calculate_defaults
    self.size = self.designable.simulator_specification.inputs.size * 30
  end
  
  def to_hash
    { size: self.size,
      map: design_values.collect {|value| value.to_hash } }
  end
  
  def to_matlab
    "struct(" + design_values.map {|value| "'#{value.input.name}',#{value.points}" }.join(",") + ")"
    # matrix = design_values.collect {|value| value.points }.transpose
    # annoying as join works on inner arrays too
    # "[#{matrix.collect {|points| points.join(',') }.join(';')}]"
  end
  
  def to_r
    "data.frame(#{design_values.collect {|value| "#{value.input.name}=c(#{value.points.join(',')})"}.join(',')})"
  end
  
  def generate
    # request hash
    {
      type: 'DesignRequest',
      size: size,
      inputs: self.simulator_specification.inputs.reject {|input| input.fixed? }.collect {|input| input.to_hash }
    }
  end
  
  def handle(response)
    # get specifications
    inputs = self.simulator_specification.inputs
    
    # parse design
    response['design']['map'].each do |set|
      input = inputs.where(:name => set['inputIdentifier']).first
      self.design_values.create(input: input, points: set['points'])
    end
  end
end
