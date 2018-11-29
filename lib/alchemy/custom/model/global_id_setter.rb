require 'active_support/concern'

module Alchemy
  module Custom
    module Model
      module GlobalIdSetter
        extend ActiveSupport::Concern

        module ClassMethods

          private

          ##
          # Metodo per ricevere un global id ed associare il relativo modello
          #
          def global_id_setter(field)

            alias_method "_old_#{field}=".to_sym, "#{field}=".to_sym

            define_method "#{field}=" do |v|
              if v.is_a?(String)
                v = GlobalID::Locator.locate_signed v
              end
              send("_old_#{field}=", v)
            end


          end


        end
      end
    end
  end
end
