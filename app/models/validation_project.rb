class ValidationProject
  include Mongoid::Document
  
  belongs_to :user

  field :observed_values, type: Array
  field :simulated_values, type: Array

end
