module Alchemy
  module Custom
    module Model
      module SlugOptimizer

        extend ActiveSupport::Concern

        included do
          validates friendly_id_config.query_field, uniqueness: {:allow_nil => true}
          before_save :prevent_wrong_slug

          private

          def prevent_wrong_slug
            self.send("#{friendly_id_config.query_field}=", normalize_friendly_id(self.slug))
          end
        end


      end
    end
  end
end