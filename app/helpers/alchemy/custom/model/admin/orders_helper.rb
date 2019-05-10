module Alchemy::Custom::Model::Admin::OrdersHelper

  def self.included(mod)
    if ::Rails.application.config.action_controller.include_all_helpers!=false
      raise "Devi definire in config/application.rb config.action_controller.include_all_helpers=false
                in modo da far funzionare correttamente l'override degli helper come per i controller"
    end
  end

  def order_path(options = {})
    new_polymorphic_path([:admin, base_class.to_s.pluralize.underscore, :order], options)
  end

  def index_ordered_path(obj = nil, options = {})
    if obj.nil?
      polymorphic_path([:admin, base_class], options)
    else
      polymorphic_path([:admin, obj], options)
    end
  end

  def update_order_path(options = {})
    polymorphic_path([:admin, base_class.to_s.pluralize.underscore, :order], options)
  end

  def print_order_identify(el)
    "el_#{el.id}"
  end

  def printelement_to_order(el)
    content_tag(:span, class: "el_title name") do
      el.name
    end
  end

  def print_sort_icon(el)
    content_tag(:span, class: "icon") do
      content_tag(:i, nil, {class: "fa fa-arrow-right"})
    end
  end


end