module Alchemy
  module Custom
    module Model
      module ElFinder
        extend ActiveSupport::Autoload

        autoload :Ability
        autoload :Connector
        autoload :Image
        autoload :PathName

        # eager_autoload do
        # end
      end
    end
  end
end
