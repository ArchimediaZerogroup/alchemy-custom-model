module Alchemy
  module Custom
    module Model
      module PicturesAltMethods

        extend ActiveSupport::Concern

        included do

          def metadata_relation
            # TO BE OVERRIDED WITH HAS_MANY RELATION OF METADATA MODEL SYMBOL
            nil
          end

          def metadata_record(language_code)
            if metadata_relation.nil?
              nil
            else
              self.send(metadata_relation).joins(:language).
                where(alchemy_languages: { language_code: language_code }).first_or_initialize
            end
          end

        end
      end
    end
  end
end
