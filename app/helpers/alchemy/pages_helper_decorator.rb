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


  # @return [Alchemy::Custom::Model::SeoModel]
  def custom_element_seo
    @custom_element.seo_model(@page)
  end

  delegate :meta_description,:meta_keywords,:meta_title,to: :custom_element_seo

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


  def custom_model_menu_recursive(inst)
    sb = ActiveSupport::SafeBuffer.new
    if inst.children.empty?
      sb << content_tag(:li) do
        link_to custom_model_path(inst) do
          content_tag(:span, inst.name)
        end
      end
    else
      sb << content_tag(:li, class: "has_children") do
        li = ActiveSupport::SafeBuffer.new
        li << link_to(custom_model_path(inst)) do
          content_tag(:span, inst.name)
        end

        li << content_tag(:ul) do
          ul = ActiveSupport::SafeBuffer.new
          inst.children.each do |ins|
            ul << custom_model_menu_recursive(ins)
          end
          ul << menu_arrow_and_back_control
          ul
        end
        li
      end
    end
    sb
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

