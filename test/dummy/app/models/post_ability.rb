class PostAbility
  include CanCan::Ability

  def initialize(user)
    if user.present? && (user.is_admin? or user.has_role?("editor"))
      can :manage, Post #model
      can :manage, :admin_posts #routes to the posts
    end
  end

end