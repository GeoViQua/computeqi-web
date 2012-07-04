class ValidationProject
  include Mongoid::Document
  
  belongs_to :user
end
