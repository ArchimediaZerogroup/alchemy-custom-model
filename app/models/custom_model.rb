
class CustomModel < ApplicationRecord
  self.abstract_class = true

  belongs_to :site, class: "Alchemy::Site"

  #
  # scope :only_current_language, -> {
  #   where(language_id: Alchemy::Language.current)
  # }

  # def self.skipped_alchemy_resource_attributes
  #   restricted_alchemy_resource_attributes
  # end

  # def self.restricted_alchemy_resource_attributes
  #   [:language, :language_id]
  # end

  before_validation :set_current_site

  def to_url
    layout = Alchemy::PageLayout.get_all_by_attributes(custom_model: self.class.to_s).select{ |ly| ly["custom_model_action"]=="show"}.first
    page = Alchemy::Language.current.pages.find_by(page_layout: layout["name"]).parent
    page.urlname
  end

  def ui_title
    self.class.to_s.demodulize.downcase
  end

  def breadcrumb_name
    self.class.to_s.demodulize.titleize
  end

  module ClassMethods
    def custom_model *translate_fields, friendly: nil
      if !column_names.include? "site_id"
        raise "You have to add site_id column to your model"
      end

        extend FriendlyId

      unless translate_fields.empty?
        translates translate_fields
      end

      unless friendly.nil?
        friendly_id friendly.to_sym, :use => [:globalize, :history]
      end

    end
  end

  private

  def set_current_site
    self.site = Alchemy::Site.current if self.site.nil?
  end
end

