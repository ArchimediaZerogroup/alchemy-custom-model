##
# Helper generale per gemma
module Alchemy::Custom::Model
  module BaseHelper

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