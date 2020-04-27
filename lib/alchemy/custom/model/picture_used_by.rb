module Alchemy
  module Custom
    module Model
      class PictureUsedBy

        def self.used_by(picture_id)
          model_to_search_for = ApplicationRecord.descendants.collect(&:name)

          finded_pictures = []
          model_to_search_for.each do |mname|
            relations = mname.constantize.reflections.collect{|c| c[0] }

            relations.each do |refc|
              relation = mname.constantize.reflections[refc]

              if relation.class_name == "Alchemy::Picture"
                begin
                  if relation.class == ActiveRecord::Reflection::BelongsToReflection
                    mm = mname.constantize.where(relation.foreign_key.to_sym => picture_id)
                    mm.each do |rec|
                      finded_pictures << rec
                    end
                  end

                  if relation.class == ActiveRecord::Reflection::ThroughReflection
                    relation_through = mname.constantize.reflections[relation.options[:through].to_s]
                    mm = relation_through.klass.where(relation.foreign_key.to_sym => picture_id)
                    mm.each do |rec|
                      rec.class.reflections.collect{|c| c[0] }.each do |relative_relation|
                        relation_relation_class = rec.class.reflections[relative_relation]
                        if relation_relation_class.class_name == mname
                          mm = relation_relation_class.klass.find( rec[relation_relation_class.foreign_key] )
                          finded_pictures << mm unless mm.nil?
                        end
                      end
                    end
                  end

                rescue Exception => excp
                  Rails.logger.error {"PictureUsedBy ERROR: #{excp.message}"}
                end
              end
            end
          end
          finded_pictures
        end

      end
    end
  end
end
