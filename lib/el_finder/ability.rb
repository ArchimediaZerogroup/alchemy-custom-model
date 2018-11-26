module ElFinder
  class Ability
    include CanCan::Ability

    def initialize(user)
      if user.present? && user.is_admin?
        can :usage, ElFinder
        can :ui_usage, ElFinder
      end
    end
  end
end


