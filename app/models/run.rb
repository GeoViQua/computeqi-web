class Run
  include Mongoid::Document
  include Remote::Remotable
  
  belongs_to :simulator_specification
  belongs_to :runnable, polymorphic: true
  belongs_to :design
  
  has_many :run_values
  
  field :size, type: Integer
  
  def to_hash
    self.run_values.collect {|value| value.to_hash }
  end
  
  def to_matlab
    "struct(" + run_values.map {|value| "'#{value.output.name}',#{value.points}" }.join(",") + ")"
    # matrix = run_values.collect {|value| value.points }.transpose
    # annoying as join works on inner arrays too
    # "[#{matrix.collect {|points| points.join(',') }.join(';')}]"
  end
  
  def to_r
    "data.frame(#{run_values.collect {|value| "#{value.output.name}=c(#{value.points.join(',')})"}.join(',')})"
  end
  
  def generate
    # get spec
    spec = self.simulator_specification
    
    # request hash
    { type: 'EvaluateProcessRequest',
      serviceURL: spec.service_url,
      processIdentifier: spec.process_name,
      inputs: spec.inputs.collect {|input| input.to_hash },
      outputs: spec.outputs.collect {|output| output.to_hash },
      design: self.design.to_hash }
  end
  
  def handle(response)
    # get project and output specifications
    outputs = self.simulator_specification.outputs
    
    # parse run
    response['evaluationResult'].each do |set|
      output = outputs.where(:name => set['outputIdentifier']).first
      self.run_values.create(output: output, points: set['results'])
    end
    
    # set size
    self.size = self.design.size
  end
end
