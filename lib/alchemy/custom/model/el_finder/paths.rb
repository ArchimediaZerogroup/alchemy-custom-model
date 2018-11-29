module Alchemy
  module Custom
    module Model
      module ElFinder::Paths
        extend ActiveSupport::Autoload

        autoload :ActiveRecordReference
        autoload :Base
        autoload :ComponentFile
        autoload :ComponentFiles
        autoload :File
        autoload :Files
        autoload :Image
        autoload :Images
        autoload :Root
        # eager_autoload do
        # end
      end
    end
  end
end
