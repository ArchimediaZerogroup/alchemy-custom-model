Alchemy::PagesHelper.module_eval do

  include CustomModelHelper

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
    if !@custom_element.nil? and @custom_element.respond_to? :meta_description
      return @custom_element.meta_description.presence || @page.meta_description
    else
      return @page.meta_description.presence || Alchemy::Language.current_root_page.try(:meta_description)
    end
  end

  def meta_keywords
    if !@custom_element.nil? and @custom_element.respond_to? :meta_keywords
      return @custom_element.meta_keywords.presence || @page.meta_keywords
    else
      return (!@custom_element.nil? and @custom_element.meta_keywords) || @page.meta_keywords.presence || Alchemy::Language.current_root_page.try(:meta_keywords)
    end
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
    bf << content_tag(:span, class:"arrow_menu arrow_up") do
      fa_icon("chevron-up")
    end
    bf << content_tag(:span, class:"arrow_menu arrow_down") do
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


end

