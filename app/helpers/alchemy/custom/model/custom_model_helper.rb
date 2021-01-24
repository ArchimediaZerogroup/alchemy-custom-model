module Alchemy::Custom::Model
  module CustomModelHelper

    def self.included(mod)
      if ::Rails.application.config.action_controller.include_all_helpers != false
        raise "Devi definire in config/application.rb config.action_controller.include_all_helpers=false
                in modo da far funzionare correttamente l'override degli helper come per i controller"
      end
    end

    def custom_model_page_urlname(obj, language: nil)
      if language.blank?
        language = Alchemy::Language.current
      end
      layout = Alchemy::PageLayout.get_all_by_attributes(custom_model: obj.class.to_s).select { |ly| ly["custom_model_action"] == "show" }.first
      if not layout.blank?
        language.pages.find_by(page_layout: layout["name"]).try(:parent).try(:urlname)
      else
        nil
      end
    end

    def custom_model_path(obj, options = {})
      language = options.delete(:language)
      custom_model_url_builder(obj, language: language) do |url|
        alchemy.show_page_path(language || Alchemy::Language.current.code, url, options)
      end
    end

    def custom_model_url(obj, options = {})
      language = options.delete(:language)
      if language.is_a? String
        language = Alchemy::Language.find_by_code(language)
      end
      custom_model_url_builder(obj, language: language) do |url|
        alchemy.show_page_url(language.code || Alchemy::Language.current.code, url, options)
      end
    end



    def search_panel(options = {}, &block)
      submit_button = options.fetch(:enable_submit, true)
      klass = options.delete(:class) || []
      
      content_tag(:div, class: "search_panel #{klass.join(" ")}", ** options) do
        sb = ActiveSupport::SafeBuffer.new
  
        if @query
          sb << content_tag(:div, class:"title") do
            spt = ActiveSupport::SafeBuffer.new
            spt << content_tag(:span, t("search_panel_title"), class:"title_label")
            
            #TODO: toggle pannello
            #spt << content_tag(:span, class:"button_toggle") do
            #  content_tag(:a,class:"icon_button") do
            #    content_tag(:i, nil, class:"icon fa-fw fa-bars fas")
            #  end
            #end
            spt
          end
  
          sb << simple_form_for(@query, url: polymorphic_path([:admin, @query.klass]), method: :get) do |f|
            sff = ActiveSupport::SafeBuffer.new
  
            field_search = @query.klass.fields_for_search.join("_or_")
            field_search += "_cont"
  
            sff << content_tag(:div, class: "search_fields_group") do
              search_fields = ActiveSupport::SafeBuffer.new
  
              search_fields << capture do
                block.call(f)
              end
  
              search_fields
            end
            if submit_button
              sff << content_tag(:div, class: "action_buttons") do
                f.submit(::I18n.t('alchemy_ajax_form.submit_search'))
              end
            end
            sff
          end
        end
        sb
      end
    end    

    private

    def custom_model_url_builder(obj, language: nil)
      to_url = custom_model_page_urlname obj, language: language
      if not to_url.blank?

        # Url build with alchemy
        url = to_url

        # Url build with model method :to_url
        url = obj.to_url if url.nil? and obj.respond_to?(:to_url)

        # Url builded with friendly id
        if url.nil?
          url = obj.class.to_s.demodulize.parameterize.underscore
        end

        url += '/'

        if obj.class.respond_to?(:friendly_id_config)
          language = Alchemy::Language.current if language.blank?
          Globalize.with_locale(language.language_code.to_sym) do
            url += "#{obj.send(obj.class.friendly_id_config.slug_column)}"
          end
        else
          url += "#{obj.id}"
        end


        if block_given?
          yield url
        else
          url
        end
      else
        "#no_page_show_custom_model"
      end
    end


    # def search_result_page
    #   @search_result_page ||= begin
    #     page = Alchemy::Page.published.find_by(
    #         page_layout: search_result_page_layout['name'],
    #         language_id: Alchemy::Language.current.id
    #     )
    #     if page.nil?
    #       logger.warn "\n++++++\nNo published search result page found. Please create one or publish your search result page.\n++++++\n"
    #     end
    #     page
    #   end
    # end
    #
    # def search_result_page_layout
    #   page_layout = Alchemy::PageLayout.get_all_by_attributes(searchresults: true).first
    #   if page_layout.nil?
    #     raise "No searchresults page layout found. Please add page layout with `searchresults: true` into your `page_layouts.yml` file."
    #   end
    #   page_layout
    # end

    # def show_svg(path)
    #   File.open(path) do |file|
    #     raw file.read
    #   end
    # end
    # def homepage_path
    #   home_page = Alchemy::Page.language_root_for(Alchemy::Language.current)
    #   show_alchemy_page_path(home_page)
    # end

    # @param [Alchemy::File] alchemy_attachment
    #   def from_mime_to_extension(alchemy_attachment)
    #     mime = MIME::Types[alchemy_attachment.file_mime_type].first
    #     I18n.t("estensione_prodotti.#{mime.i18n_key}", default: mime.preferred_extension)
    #   end

    #
    #
    # def extract_video_id_from_link(link)
    #   vid_regex = /(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
    #   link.match(vid_regex).try(:[], 1)
    # end
    #
    # def youtube_video_thumb_url(video_link)
    #   video_id = extract_video_id_from_link video_link
    #   if not video_id.blank?
    #     "https://img.youtube.com/vi/#{video_id}/hqdefault.jpg"
    #   end
    # end
  end
end
