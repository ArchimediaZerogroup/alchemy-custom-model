require "alchemy_cms"
require "jquery/ui/rails"
require "el_finder"
require "friendly_id"
require "globalize"
require 'friendly_id/globalize'
require "active_type"
require "alchemy/custom/model/engine"


module Alchemy
  extend ActiveSupport::Autoload
  autoload :NodeDec

  module Admin
    extend ActiveSupport::Autoload
    autoload :NodesControllerDec
  end


  module Custom
    module Model
      extend ActiveSupport::Autoload

      autoload :ElFinder
      autoload :GlobalIdSetter
      autoload :MenuMethods
      autoload :SlugOptimizer
      autoload :ModelDecoration
      autoload :TranslationScope
      autoload :PagesControllerDec
      autoload :PictureUsedBy
      autoload :ModelUtilsMethod
      autoload :GlobalizeModelDecoration



      mattr_accessor :base_admin_controller_class

      @@base_admin_controller_class = 'Alchemy::Admin::BaseController'

      mattr_accessor :allowed_custom_models_for_menu
      @@allowed_custom_models_for_menu = []


      def self.admin_controller_class
        @@base_admin_controller_class.constantize
      end
    end
  end
end
