module Alchemy::Custom::Model
  module GlobalizeModelDecoration
    extend ActiveSupport::Concern

    included do

      include GlobalIdSetter
      include MenuMethods
      include ModelUtilsMethods
      include SitemapMethods



      def self.use_friendly(base = nil, options = {}, &block)
        extend FriendlyId

        self.friendly_id(base, options.merge(use: [:globalize]), &block)

        include SlugOptimizer

      end

    end

  end
end