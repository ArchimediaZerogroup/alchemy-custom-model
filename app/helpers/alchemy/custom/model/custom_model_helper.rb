module Alchemy::Custom::Model
  module CustomModelHelper

    def CustomModelHelper.included(mod)
      if ::Rails.application.config.action_controller.include_all_helpers!=false
        raise "Devi definire in config/application.rb config.action_controller.include_all_helpers=false
                in modo da far funzionare correttamente l'override degli helper come per i controller"
      end
    end

    def custom_model_page_urlname(obj)
      layout = Alchemy::PageLayout.get_all_by_attributes(custom_model: obj.class.to_s).select {|ly| ly["custom_model_action"] == "show"}.first
      if not layout.blank?
        Alchemy::Language.current.pages.find_by(page_layout: layout["name"]).try(:parent).try(:urlname)
      else
        nil
      end
    end

    def custom_model_path(obj)
      custom_model_url_builder(obj) do |url|
        alchemy.show_page_path(Alchemy::Language.current.code, url)
      end
    end

    def custom_model_url(obj)
      custom_model_url_builder(obj) do |url|
        alchemy.show_page_url(Alchemy::Language.current.code, url)
      end
    end

    private

    def custom_model_url_builder(obj)
      to_url = custom_model_page_urlname obj
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
          url += "#{obj.send(obj.class.friendly_id_config.slug_column)}"
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
