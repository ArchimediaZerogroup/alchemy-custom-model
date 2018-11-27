module Alchemy
  module Custom
    module Model
      class Engine < ::Rails::Engine
        #isolate_namespace Alchemy
        #

        config.autoload_paths << config.root.join('lib')

        initializer "alchemy_custom_model.assets.precompile" do |app|
          app.config.assets.precompile << 'alchemy_custom_model_manifest.js'
          app.config.assets.paths << config.root.join("vendor", "elfinder")

        end

      end
    end
  end
end
