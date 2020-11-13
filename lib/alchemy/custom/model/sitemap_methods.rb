module Alchemy
  module Custom
    module Model
      module SitemapMethods

        extend ActiveSupport::Concern

        included do

          def self.to_sitemap
            all
          end

        end
      end
    end
  end
end
