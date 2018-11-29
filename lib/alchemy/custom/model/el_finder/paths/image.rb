module Alchemy::Custom::Model::ElFinder
  module Paths
    class Image < Paths::File

      #
      # url per la thumb
      def tmb
        active_record_instance.image_file.thumb('100x100#').url
      end

      def full_fill_paylod(payload)
        payload[:tmb] = self.tmb
        payload[:original_url] = active_record_instance.image_file.url
        payload
      end

      def active_record_class
        ::Alchemy::Picture
      end

      def file
        active_record_instance.image_file
      end

      def file=(val)
        active_record_instance.image_file = val
      end

      delegate :save, to: :active_record_instance

      def is_image?
        true
      end


      def dim
        "#{active_record_instance.image_file_width}x#{active_record_instance.image_file_height}"
      end
    end
  end
end

