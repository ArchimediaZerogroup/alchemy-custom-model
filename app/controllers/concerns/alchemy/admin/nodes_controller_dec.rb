module Alchemy
  module Admin
    module NodesControllerDec
      extend ActiveSupport::Concern

      included do

        def custom_models
          @custom_model_klasses = Alchemy::Custom::Model.allowed_custom_models_for_menu
          if params[:q] and params[:q][:name]
            @custom_model_klasses = @custom_model_klasses.select { |el| el.match /#{params[:q][:name]}/i }
          end
          @custom_model_klasses = Kaminari.paginate_array(@custom_model_klasses).page(params[:page]).per(params[:per_page] || 10)

        end

        def custom_models_methods
          @custom_model_klasses = Alchemy::Custom::Model.allowed_custom_models_for_menu
          @custom_model_methods = []
          if params[:q] and params[:q][:custom_model_klass]
            klass = Alchemy::Custom::Model.allowed_custom_models_for_menu.select { |el| el == params[:q][:custom_model_klass] }.first
            if !klass.nil? and klass.safe_constantize
              klass = klass.constantize
              if klass.respond_to? :menu_generator_methods
                @custom_model_methods = klass.menu_generator_methods
              end
            end
          end
          @custom_model_methods = Kaminari.paginate_array(@custom_model_methods).page(params[:page]).per(params[:per_page] || 10)
        end


        private

        def resource_params
          params.require(:node).permit(
              :site_id,
              :parent_id,
              :language_id,
              :page_id,
              :name,
              :url,
              :title,
              :nofollow,
              :external,
              :custom_model_klass,
              :custom_model_method,
              :menu_type
          )
        end


      end
    end
  end
end