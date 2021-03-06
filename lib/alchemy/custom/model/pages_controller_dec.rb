module Alchemy::Custom::Model
  module PagesControllerDec

    extend ActiveSupport::Concern

    included do

      skip_before_action :page_not_found!, only: [:index, :show]
      before_action :load_custom_model_page, only: [:show]
      before_action :page_not_found_after_custom_model!, if: -> { @page.blank? }, only: [:index, :show]
      before_action :perform_search, only: :show
      after_action :set_404_after, except: :sitemap

      helper CustomModelHelper

      def sitemap
        @pages = Alchemy::Page.sitemap.reject do |page|
          page.definition["custom_model_action"].to_s == "show"
        end
        @custom_elements = []
        Alchemy::Custom::Model.sitemaps_models.each do |model|
          if model.respond_to? :to_sitemap
            @custom_elements << model.to_sitemap
          end
        end
        @custom_elements = @custom_elements.flatten
        respond_to do |format|
          format.xml { render layout: 'alchemy/sitemap' }
        end
      end

      private

      def load_custom_model_page
        if !@page.nil?
          custom_model_string = get_custom_model_string

          unless custom_model_string.blank?

            custom_model = custom_model_string.classify.constantize

            @q = custom_model.ransack(params[:q])
            @custom_elements = @q.result.
              page(params[:page]).per(params[:per_page])
            @custom_elements = @custom_elements.only_current_language
            instance_variable_set("@#{custom_model_string.demodulize.downcase.pluralize}", @custom_elements)
          end

        elsif action_name == "sitemap"
          super
        else

          url = params[:urlname]

          url_params = url.match(/(?<page_name>.*)\/(?<custom_model_id>[^\/]+)$/)

          unless url_params.nil?

            parent_page = Alchemy::Language.current.pages.contentpages.find_by(
              urlname: url_params[:page_name],
              language_code: params[:locale] || Alchemy::Language.current.code
            )

            if parent_page.nil?
              Rails.logger.warn "Parent Page not Found [#{url_params[:page_name]}]"
              #TODO magari implementare ricerca children in base a una action es. edit new chow ecc
            else
              @page = parent_page.children.first
              if @page.nil?
                Rails.logger.warn "You have to define a subpage for custom model"
              else
                custom_model_string = get_custom_model_string

                if custom_model_string.blank?
                  Rails.logger.warn "You have to specify custom_model in page_layouts config file"
                else
                  custom_model = custom_model_string.classify.constantize
                  @custom_element = custom_model.only_current_language.friendly.find(url_params[:custom_model_id])
                  instance_variable_set("@#{custom_model_string.demodulize.underscore}", @custom_element)
                end

              end

            end

          end

        end
      end

      def perform_search
        return if params[:query].blank?
        @search_results = search_results
        if params[:per_page] or paginate_per
          if @search_results.is_a? Array
            @search_results = Kaminari.paginate_array(@search_results).page(params[:page]).per(paginate_per)
          else
            @search_results = @search_results.page(params[:page]).per(params[:per_page] || paginate_per)
          end
        end
      end

      def search_results
        pages = Alchemy::Page.published.contentpages.with_language(Alchemy::Language.current.id)
        # Since CanCan cannot (oh the irony) merge +accessible_by+ scope with pg_search scopes,
        # we need to fake a page object here
        if can? :show, Alchemy::Page.new(restricted: true, public_on: Date.current)
          pages.search(params[:query], params[:whitelist_custom_model])
        else
          pages.not_restricted.search(params[:query], params[:whitelist_custom_model])
        end
      end

      def get_custom_model_string

        children_page_layout = Alchemy::PageLayout.get(@page.page_layout)

        children_page_layout["custom_model"]

      end

      def page_not_found_after_custom_model!
        not_found_error!("Alchemy::Page not found \"#{request.fullpath}\"")
      end

      def paginate_per
        ArchimediaPgsearch::SEARCH_RESULTS_PAGINATION_NUMBER
      end

      def not_found_error!(msg = "Not found \"#{request.fullpath}\"")
        not_found_page = Alchemy::Language.current.pages.published.find_by(page_layout: "not_found")
        if !not_found_page.nil?
          @page = not_found_page
        else
          raise ActionController::RoutingError, msg
        end
      end

      def set_404_after
        if @page.page_layout == "not_found"
          response.status = 404
        end
      end

    end

  end
end