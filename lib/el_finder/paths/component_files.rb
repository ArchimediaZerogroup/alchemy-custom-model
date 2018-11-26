module ElFinder
  module Paths
    class ComponentFiles < Base


      def children(with_directory = true)

        @volume.record.send(@volume.attribute).collect do |p|

          build_file_path(p)

        end

      end

      ##
      # Costruisce il singolo file, passandogli l'active record di alchemy (Picture o Attachment)
      #
      # @param [Alchemy::Picture | Alchemy::Attachment] p
      def build_file_path(p)

        base_class = ElFinder::Paths::ComponentFile


        file_path = base_class.new(@root, "#{self.path}/#{base_class.file_to_uri(p)}", volume: self.volume)

        file_path.active_record_instance = p

        file_path
      end

    end
  end
end
