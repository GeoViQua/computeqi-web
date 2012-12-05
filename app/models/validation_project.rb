class ValidationProject
  include Mongoid::Document

  belongs_to :user
  has_one :validation, dependent: :destroy

  field :name, type: String

  def allow_validation?
    true
  end

  def complete?
    !self.validation.nil? and self.validation.success?
  end
end