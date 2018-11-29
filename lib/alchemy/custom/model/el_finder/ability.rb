module Alchemy::Custom::Model
  module ElFinder
    class Ability
      include CanCan::Ability

      def initialize(user)
        if user.present? && user.is_admin?
          can :usage, Alchemy::Custom::Model::ElFinder
          can :ui_usage, Alchemy::Custom::Model::ElFinder
        end
      end
    end
  end
end


