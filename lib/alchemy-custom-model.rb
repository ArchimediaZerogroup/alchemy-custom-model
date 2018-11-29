require "alchemy_cms"
require "jquery/ui/rails"
require "el_finder"
require "alchemy/custom/model/engine"


module Alchemy
  module Custom
    module Model
      extend ActiveSupport::Autoload

      autoload :GlobalIdSetter
      autoload :ModelDecoration
      autoload :TranslationScope

    end
  end
end
