##
# Helper generale per gemma
module Alchemy::Custom::Model
  module BaseHelper


    def self.included(mod)
      if ::Rails.application.config.action_controller.include_all_helpers!=false
        raise "Devi definire in config/application.rb config.action_controller.include_all_helpers=false
                in modo da far funzionare correttamente l'override degli helper come per i controller"
      end
    end

    include TranslationScope


    def print_current_site_language
      content_tag(:div, class: "current_site_language") do
        acm_t(:you_are_editing_site_language,
              site: Alchemy::Site.current.name,
              language: Alchemy::Language.current.name).html_safe
      end
    end






  end
end