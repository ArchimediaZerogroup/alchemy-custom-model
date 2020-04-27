module Alchemy
  module Custom
    module Model
      module MenuMethods

        extend ActiveSupport::Concern

        included do

          class_attribute :menu_generator_methods, default: []

        end
      end
    end
  end
end