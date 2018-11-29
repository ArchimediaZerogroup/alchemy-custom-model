module Alchemy::Custom::Model::ElFinder
  module Paths
    class Files < Base

      def children(with_directory = true)
        ::Alchemy::Attachment.all.collect {|p|
          build_file_path(p)
        }
      end

      def build_file_path(p)
        base_class = File

        Rails.logger.debug {"#{@root}-#{self.path}"}
        image = base_class.new(@root, "#{self.path}/#{base_class.file_to_uri(p)}")

        image.active_record_instance = p

        image
      end

    end
  end
end

