require "alchemy_cms"
require "jquery/ui/rails"
require "el_finder"
require "friendly_id"
require "alchemy/custom/model/engine"


module Alchemy
  module Custom
    module Model
      extend ActiveSupport::Autoload

      autoload :GlobalIdSetter
      autoload :ModelDecoration
      autoload :TranslationScope
      autoload :PagesControllerDec


      mattr_accessor :base_admin_controller_class

      @@base_admin_controller_class = 'Alchemy::Admin::BaseController'


      def self.admin_controller_class
        @_admin_class ||= @@base_admin_controller_class.constantize
      end
    end
  end
end
