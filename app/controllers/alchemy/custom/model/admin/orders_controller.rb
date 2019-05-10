module Alchemy::Custom::Model
  module Admin
    class OrdersController < ::Alchemy::Custom::Model::Admin::BaseController


      skip_before_action :load_object
      skip_before_action :clean_slug

      include Alchemy::Custom::Model::Order

      private

      def url_namespace
        [:admin,base_class.to_s.underscore.pluralize, :order]
      end




    end
  end
end
