Alchemy::PagesHelper.module_eval do

  include Alchemy::Custom::Model::CustomModelHelper

  def page_title(options = {})
    return "" if !@custom_element.nil? and @custom_element.respond_to? :meta_title and
      @custom_element.meta_title.presence and @page.title.blank?
    options = {
      prefix: "",
      separator: ""
    }.update(options)
    title_parts = [options[:prefix]]
    if response.status == 200
      if !@custom_element.nil? and @custom_element.respond_to? :meta_title
        title_parts << (@custom_element.meta_title.presence || @page.title)
      else
        title_parts << @page.title
      end
    else
      title_parts << response.status
    end
    title_parts.join(options[:separator]).html_safe
  end


  def meta_description

    meta_description = @page.meta_description

    if !@custom_element.nil? and @custom_element.respond_to? :meta_description
      meta_description = @custom_element.meta_description || @page.meta_description
    end

    meta_description || Alchemy::Language.current_root_page.try(:meta_description)

  end

  def meta_keywords

    meta_keywords = @page.meta_keywords

    if !@custom_element.nil? and @custom_element.respond_to? :meta_keywords
      meta_keywords = @custom_element.meta_keywords.presence || @page.meta_keywords
    end

    meta_keywords || Alchemy::Language.current_root_page.try(:meta_keywords)

  end

  def meta_robots
    return "noindex,nofollow" if Rails.env.to_sym != :production

    if !@custom_element.nil? and @custom_element.respond_to? :robot_index? and @custom_element.respond_to? :robot_follow?
      "#{(@custom_element.robot_index?.presence or @page.robot_index?) ? '' : 'no'}index, #{(@custom_element.robot_follow?.presence || @page.robot_follow?) ? '' : 'no'}follow"
    else
      "#{ @page.robot_index? ? '' : 'no'}index, #{@page.robot_follow? ? '' : 'no'}follow"

    end
  end

  def menu_arrow_and_back_control
    bf = ActiveSupport::SafeBuffer.new
    bf << content_tag(:div, class: "back d-block d-xl-none") do
      content_tag(:span) do
        back = ActiveSupport::SafeBuffer.new
        back << fa_icon("angle-left")
        back << ' BACK'
        back
      end
    end
    bf << content_tag(:span, class: "arrow_menu arrow_up") do
      fa_icon("chevron-up")
    end
    bf << content_tag(:span, class: "arrow_menu arrow_down") do
      fa_icon("chevron-down")
    end
    bf
  end


  def language_links_by_page(current_page)
    r = []
    Alchemy::Language.on_current_site.published.with_root_page.collect {|lang|
      page = Alchemy::Page.published.with_language(lang.id).where(name: current_page.name).first
      if not page.nil? and lang != Alchemy::Language.current
        url_page = show_page_path_params(page).merge(locale: lang.code)
        r << content_tag(:link, nil, href: url_page[:locale] + '/' + url_page[:urlname], hreflang: lang.code, rel: "alternate")
      end
    }
    r.join().html_safe
  end


end

