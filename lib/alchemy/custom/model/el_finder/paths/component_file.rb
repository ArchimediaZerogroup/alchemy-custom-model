module Alchemy::Custom::Model::ElFinder
  module Paths
    class ComponentFile < ActiveRecordReference

      def active_record_class
        self.volume.attribute_class
      end

      def alchemy_record
        return @_alch_record_cache if @_alch_record_cache
        base = active_record_instance
        self.volume.file_link_ref.split('.').each {|m| base = base.try(m)}
        @_alch_record_cache = base
      end

      def file
        case alchemy_record
        when ::Alchemy::Attachment
          alchemy_record.file
        when ::Alchemy::Picture
          alchemy_record.image_file
        end
      end


      def file=(val)
        case alchemy_record
        when ::Alchemy::Attachment
          alchemy_record.file = val
        when ::Alchemy::Picture
          alchemy_record.image_file = val
        end
      end

      delegate :save, to: :alchemy_record

      def full_fill_paylod(payload)
        payload[:tmb] = self.tmb
        payload
      end


      def tmb
        case alchemy_record
        when ::Alchemy::Attachment
          ''
        when ::Alchemy::Picture
          file.thumb('100x100#').url
        end

      end

      def is_image?
        alchemy_record.is_a? ::Alchemy::Picture
      end

    end
  end
end
