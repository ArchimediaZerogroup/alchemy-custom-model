module ElFinder
  module Paths
    class Images < Base


      def children(with_directory = true)
        Alchemy::Picture.all.collect {|p|
          build_file_path(p)
        }
      end

      ##
      # Costruisce il singolo file, passandogli l'active record di alchemy (Picture o Attachment)
      #
      # @param [Alchemy::Picture | Alchemy::Attachment] p
      def build_file_path(p)

        base_class = ElFinder::Paths::Image

        Rails.logger.debug {"#{@root}-#{self.path}"}
        image = base_class.new(@root, "#{self.path}/#{base_class.file_to_uri(p)}")

        image.active_record_instance = p

        image
      end


    end
  end
end
