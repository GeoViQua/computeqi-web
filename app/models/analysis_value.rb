class AnalysisValue
  include Mongoid::Document

  belongs_to :analysis
  belongs_to :output
  has_many :analysis_input_values

  mount_uploader :plot, AnalysisPlotUploader
  
  def to_r  
    "r"
  end
  
  def to_matlab
    "matlab"
  end
  
  def to_hash
    { outputIdentifier: self.output.name,
      inputResults: self.analysis_input_values.collect {|value| value.to_hash } }
  end
end
