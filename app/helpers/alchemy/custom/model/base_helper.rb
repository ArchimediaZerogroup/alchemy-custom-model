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

end