module Alchemy
  module NodeDec

    extend ActiveSupport::Concern

    included do

      validates :custom_model_klass, presence: true, if: -> {
        url.blank? and not parent.nil?
      }

      before_validation :ensure_page_nil_if_custom_model, on: [:create, :update]
      before_validation :set_site, on: [:create], if: -> {site.nil?}

      def custom_model?
        !custom_model_klass.blank?
      end

      def klass_custom_model
        self.custom_model_klass.constantize
      end

      private

      def ensure_page_nil_if_custom_model
        if not url.blank? and !custom_model_klass_changed? and !custom_model_method_changed?
          self.custom_model_klass = nil
          self.custom_model_method = nil
        elsif !custom_model_klass.blank? and !url_changed?
          self.page = nil
          self.url = nil
        end

      end

      def set_site
        unless self.language.nil?
          self.site = language.site
        end
      end


    end
  end
end