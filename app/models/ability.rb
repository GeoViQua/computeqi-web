class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, EmulatorProject, :user_id => user.id
    can :manage, SensitivityProject, :user_id => user.id
    can :manage, ValidationProject, :user_id => user.id
  end
end
