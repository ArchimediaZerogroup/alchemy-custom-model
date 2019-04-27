module Alchemy
  module Custom
    module Model
      module Admin
        class ClonesController < BaseController
          def create
            @obj.assign_attributes clean_params
            if @parent.present? and @obj.respond_to?("#{parent_model_name_demodulized}=".to_sym)
              @obj.send "#{parent_model_name_demodulized}=", @parent
            end
            @obj = yield @obj if block_given?
            if @obj.apply
              after_successfull_create
            else
              after_unsuccessfully_create
            end
          end

          private

          def authorize_resource
            authorize!(:clone, @parent.class)
          end

          def base_class
            "::#{parent_model_name_demodulized.classify}Cloner".constantize
          end

          def after_successfull_create
            url = polymorphic_path [:admin, @parent.class]
            flash[:notice] = t(:record_succesfully_cloned, model: @parent.class.model_name.human)
            respond_to do |format|
              format.js {
                @redirect_url = url
                render :redirect
              }
              format.html {redirect_to url}
            end
          end

          def after_unsuccessfully_create
            render :new
          end

          def permitted_attributes
            base_class._virtual_column_names.collect(&:to_sym)
          end


        end
      end
    end
  end
end
