module Alchemy
  module Custom
    module Model
      module Admin
        class BaseWithGlobalizeController < BaseController


          around_action :switch_globalize_locale
          before_action :load_object, except: :index


          def index
            @query = base_class.ransack(params[:q])
            @objects = @query.result(distinct: true)
            @objects = @objects.accessible_by(current_ability)
            @total_objects = @objects
            @objects = @objects.page(params[:page]).
                per(params[:per_page] ||
                        (base_class::DEFAULT_PER_PAGE if base_class.const_defined? :DEFAULT_PER_PAGE) ||
                        25)
            instance_variable_set "@#{base_class.name.demodulize.underscore.downcase.pluralize}", @objects
          end



          private

          def switch_globalize_locale(&action)
            locale = Alchemy::Language.current.language_code.to_sym
            Globalize.with_locale(locale, &action)
          end


        end
      end
    end
  end
end
