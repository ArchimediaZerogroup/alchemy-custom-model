##
# Helper generale per gemma
module Alchemy::Custom::Model::BaseHelper

  ##
  # Methodo per le traduzioni scoppate sulla gemma
  def acm_t(*args)
    options = args.last.is_a?(Hash) ? args.pop.dup : {}
    key = args.shift


    options[:scope] = "alchemy_custom_model#{options[:scope] ? ".#{options[:scope]}" : ""}"

    I18n.t(key, options)

  end

  def print_current_site_language
    content_tag(:div, class: "current_site_language") do
      acm_t(:you_are_editing_site_language,
            site: Alchemy::Site.current.name,
            language: Alchemy::Language.current.name).html_safe
    end
  end

end