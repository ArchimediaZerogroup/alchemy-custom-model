module Alchemy
  module Custom
    module Model
      class Engine < ::Rails::Engine
        isolate_namespace Alchemy::Custom::Model
        #engine_name 'alchemy'

        config.autoload_paths << config.root.join('lib')

        initializer "alchemy_custom_model.assets.precompile" do |app|
          app.config.assets.precompile << 'alchemy_custom_model_manifest.js'
          app.config.assets.precompile << 'elfinder/css/elfinder.min.css'
          app.config.assets.precompile << 'elfinder/css/theme.css'
          app.config.assets.paths << config.root.join("vendor")

        end

        config.to_prepare do

          Alchemy::PagesController.include(PagesControllerDec)

          # load degli helpers per alchemy
          [
            Alchemy::Custom::Model::Engine.root.join('app', 'helpers', 'alchemy', 'pages_helper_decorator.rb')
          ].each do |f|
            Rails.configuration.cache_classes ? require(f) : load(f)
          end


        end


        # initializer "alchemy_richmedia_essences.register_ability" do
        #   Alchemy.register_ability Alchemy::Richmedia::Essences::Ability
        # end

      end
    end
  end
end
