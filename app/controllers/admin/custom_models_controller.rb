module Admin
  class CustomModelsController < ::Alchemy::Admin::ResourcesController
    helper_method :switch_lang_path
    before_action :load_languages

    include FriendlyLoader

    def update
      resource_instance_variable.alchemy_element.update_contents(contents_params)
      super
    end

    def create
      instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.new(resource_params))
      instance_variable_get("@#{resource_handler.resource_name}").language_id = Alchemy::Language.current.id
      resource_instance_variable.save
      render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_handler.namespaced_resources_name, current_location_params),
          flash_notice_for_resource_action
      )
    end

    def index
      @query = resource_handler.model.ransack(params[:q])
      items = @query.result

      if contains_relations?
        items = items.includes(*resource_relations_names)
      end

      if params[:tagged_with].present?
        items = items.tagged_with(params[:tagged_with])
      end

      if params[:filter].present?
        items = items.public_send(sanitized_filter_params)
      end

      items = items.only_current_language


      respond_to do |format|
        format.html {
          items = items.page(params[:page] || 1).per(per_page_value_for_screen_size)
          instance_variable_set("@#{resource_handler.resources_name}", items)
        }
        format.csv {
          instance_variable_set("@#{resource_handler.resources_name}", items)
        }
      end
    end


    def switch_language
      set_alchemy_lale#bang
      # anguage(params[:language_id])
      Rails.logger.debug {"Lingua i18n: #{I18n.locale}"}
      Rails.logger.debug {"Lingua Alchemy: #{Alchemy::Language.current.language_code}"}
      redirect_to switch_lang_redirect
    end

    def edit
      if resource_instance_variable.alchemy_element.nil?
        resource_instance_variable.initialize_essence_elements
      end
      super
    end


    private
    def contents_params
      params.fetch(:contents, {}).permit!
    end


    def load_languages
      @languages = Alchemy::Language.on_current_site
    end


    def switch_lang_path
      raise "Override"
    end

    def switch_lang_redirect
      raise "Override"
    end
  end
end