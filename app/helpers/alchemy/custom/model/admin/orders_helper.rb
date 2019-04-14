module Alchemy::Custom::Model::Admin::OrdersHelper
  def order_path(options = {})
    new_polymorphic_path([:admin, base_class.to_s.pluralize.underscore, :order], options)
  end

  def index_ordered_path(options = {})
    polymorphic_path([:admin, base_class], options)
  end

  def print_order_identify(el)
    "el_#{el.id}"
  end

  def printelement_to_orderr(el)
    content_tag(:span, class: "el_title name") do
      el.name
    end
  end

  def print_sort_icon(el)
    content_tag(:span, class: "icon") do
      content_tag(:i, nil, {class: "fa fa-arrow-right"})
    end
  end

  def print_order_tree
    content_tag(:ol, class: "order_tree sortaable_tree margined", id: "sort_tree") do
      el_buf = ActiveSupport::SafeBuffer.new
      @elements.each do |el|
        el_buf << content_tag(:li, id: print_order_identify(el)) do
          sb = ActiveSupport::SafeBuffer.new
          sb << content_tag(:div, class: "el_block") do
            div = ActiveSupport::SafeBuffer.new
            div << print_sort_icon(el)
            div << content_tag(:div, class: "el_value") do
              printelement_to_order el
            end
          end
          sb
        end
      end
      el_buf
    end
  end


end