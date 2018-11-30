module Alchemy::Custom::Model
  module ModelDecoration
    extend ActiveSupport::Concern

    included do

      include GlobalIdSetter

      belongs_to :language, class_name: "Alchemy::Language"


      before_validation :set_current_language


      scope :only_current_language, -> {
        where(language_id: Alchemy::Language.current.id)
      }

      def to_url
        layout = Alchemy::PageLayout.get_all_by_attributes(custom_model: self.class.to_s).select {|ly| ly["custom_model_action"] == "show"}.first
        page = Alchemy::Language.current.pages.find_by(page_layout: layout["name"]).parent
        page.urlname
      end

      def ui_title
        self.class.to_s.demodulize.downcase
      end

      def breadcrumb_name
        self.class.to_s.demodulize.titleize
      end

      def seo_model(page)
        SeoModel.new(self, page)
      end


      # module ClassMethods
      #   def custom_model *translate_fields, friendly: nil
      #     if !column_names.include? "site_id"
      #       raise "You have to add site_id column to your model"
      #     end
      #
      #       extend FriendlyId
      #
      #     unless translate_fields.empty?
      #       translates translate_fields
      #     end
      #
      #     unless friendly.nil?
      #       friendly_id friendly.to_sym, :use => [:globalize, :history]
      #     end
      #
      #   end
      # end

      private

      def set_current_language
        if self.language.nil?
          self.language = Alchemy::Language.current
        end
      end


    end


    module ClassMethods

      private

      def set_slug_if_present
        if column_names.include? "slug"
          validates :slug, uniqueness: true
          before_save :prevent_wrong_slug

          define_method :prevent_wrong_slug do
            self.slug = normalize_friendly_id self.slug
          end
        end
      end
    end
  end
end