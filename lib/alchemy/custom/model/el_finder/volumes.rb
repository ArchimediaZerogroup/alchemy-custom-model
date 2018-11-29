module Alchemy
  module Custom
    module Model
      module ElFinder::Volumes
        extend ActiveSupport::Autoload

        autoload :AlchemyFile
        autoload :AlchemyFiles
        autoload :AlchemyImages
        autoload :Base
        autoload :ComponentAttribute

        # eager_autoload do
        # end
      end
    end
  end
end
