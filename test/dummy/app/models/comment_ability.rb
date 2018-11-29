class CommentAbility
  include CanCan::Ability

  def initialize(user)
    if user.present? && (user.is_admin? or user.has_role?("editor"))
      can :manage, Comment #model
    end
  end

end