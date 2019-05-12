module Alchemy
  module Custom
    module Model
      class Cloner < ::ActiveType::Object



        attribute :language_id, :integer
        attribute :site_id, :integer

        validates :language_id, :site_id, presence: true
        validate :check_lang_in_site, unless: -> {site_id.blank?}


        ###
        # ritorna true se il clone è andato a buon fine false altrimenti
        def apply
          if valid?
            cloned = self.send(self.to_cloner_name).clone_to_other_lang(get_attributes_for_clone.with_indifferent_access)
            if cloned.valid?
              true
            else
              cloned.errors.full_messages.each do | error|
                self.errors.add(:base, error)
              end
              false
            end
          else
            false
          end
        end



        private
        
        class << self
          def cloner_of(name,scope = nil, options={})
            class_attribute :to_cloner_name
            name = name.to_sym
            if options[:foreign_key]
              attribute options[:foreign_key]
            else
              attribute :"#{name}_id"
            end
            belongs_to name, scope, options
            self.to_cloner_name = name
          end
        end
        
        def get_attributes_for_clone
          self.attributes
        end
        
        
        protected

        def check_lang_in_site
          site = Alchemy::Site.find self.site_id
          if !site.languages.pluck(:id).include? self.language_id
            errors.add(:language_id, :isnt_in_site)
          end
        end

      end
    end
  end
end