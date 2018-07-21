module Alchemy
  module Custom
    module Model
      class Engine < ::Rails::Engine
        isolate_namespace Alchemy::Custom::Model
      end
    end
  end
end
