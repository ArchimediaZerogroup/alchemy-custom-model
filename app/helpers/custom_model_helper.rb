module CustomModelHelper
  def custom_model_page_urlname obj
    layout = Alchemy::PageLayout.get_all_by_attributes(custom_model: obj.class.to_s).select {|ly| ly["custom_model_action"] == "show"}.first
    if not layout.blank?
      page = Alchemy::Language.current.pages.find_by(page_layout: layout["name"]).parent
      page.urlname
    else
      nil
    end
  end

  def custom_model_path obj
    to_url = custom_model_page_urlname obj
    if not to_url.blank?
      alchemy.show_page_path(Alchemy::Language.current.code,
                             "#{to_url || obj.try(:to_url) ||
                                 obj.class.to_s.demodulize.parameterize.underscore}/#{obj.send(obj.class.try(:friendly_id_config).try(:slug_column)) ||
                                 obj.id}")
    else
      "#no_page_show_custom_model"
    end
  end

  def custom_model_url obj
    to_url = custom_model_page_urlname obj
    alchemy.show_page_url(Alchemy::Language.current.code,
                          "#{to_url || obj.try(:to_url) ||
                              obj.class.to_s.demodulize.parameterize.underscore}/#{obj.send(obj.class.try(:friendly_id_config).try(:slug_column)) ||
                              obj.id}")
  end


  def search_result_page
    @search_result_page ||= begin
      page = Alchemy::Page.published.find_by(
          page_layout: search_result_page_layout['name'],
          language_id: Alchemy::Language.current.id
      )
      if page.nil?
        logger.warn "\n++++++\nNo published search result page found. Please create one or publish your search result page.\n++++++\n"
      end
      page
    end
  end

  def search_result_page_layout
    page_layout = Alchemy::PageLayout.get_all_by_attributes(searchresults: true).first
    if page_layout.nil?
      raise "No searchresults page layout found. Please add page layout with `searchresults: true` into your `page_layouts.yml` file."
    end
    page_layout
  end

  def show_svg(path)
    File.open(path) do |file|
      raw file.read
    end
  end
  def homepage_path
    home_page = Alchemy::Page.language_root_for(Alchemy::Language.current)
    show_alchemy_page_path(home_page)
  end

# @param [Alchemy::File] alchemy_attachment
  def from_mime_to_extension(alchemy_attachment)
    mime = MIME::Types[alchemy_attachment.file_mime_type].first
    I18n.t("estensione_prodotti.#{mime.i18n_key}", default: mime.preferred_extension)
  end



  def extract_video_id_from_link(link)
    vid_regex = /(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
    link.match(vid_regex).try(:[], 1)
  end

  def youtube_video_thumb_url(video_link)
    video_id = extract_video_id_from_link video_link
    if not video_id.blank?
      "https://img.youtube.com/vi/#{video_id}/hqdefault.jpg"
    end
  end
end
