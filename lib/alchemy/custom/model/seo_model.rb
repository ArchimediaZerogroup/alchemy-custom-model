##
#
# Classe che si occupa di estrapolare le corrette informazioni per il seo del custom model
# se il custom model non implementa le colonne per il seo, questi dati verranno presi dalla pagina di Alchemy
#
##
module Alchemy::Custom::Model
  class SeoModel

    attr_accessor :model, :page

    # @param [ActiveRecord] model decorated with custom model
    # @param [Object] page Alchemy::Page
    def initialize(model, page)

      @model = model
      @page = page

    end


    def meta_description

      meta_description = @page.meta_description

      if !@model.nil? and @model.respond_to? :meta_description
        meta_description = @model.meta_description || @page.meta_description
      end

      meta_description || Alchemy::Language.current_root_page.try(:meta_description)

    end

    def meta_keywords

      meta_keywords = @page.meta_keywords

      if !@model.nil? and @model.respond_to? :meta_keywords
        meta_keywords = @model.meta_keywords.presence || @page.meta_keywords
      end

      meta_keywords || Alchemy::Language.current_root_page.try(:meta_keywords)

    end

    def meta_robots
      return "noindex,nofollow" if Rails.env.to_sym != :production

      if !@model.nil? and @model.respond_to? :robot_index? and @model.respond_to? :robot_follow?
        "#{(@model.robot_index?.presence or @page.robot_index?) ? '' : 'no'}index, #{(@model.robot_follow?.presence || @page.robot_follow?) ? '' : 'no'}follow"
      else
        "#{ @page.robot_index? ? '' : 'no'}index, #{@page.robot_follow? ? '' : 'no'}follow"

      end
    end

  end
end