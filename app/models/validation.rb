class Validation
  include Mongoid::Document

  field :observed, type: Array
  field :predicted, type: Object
  field :rmse, type: Float
  field :standard_scores, type: Array
  
  
end