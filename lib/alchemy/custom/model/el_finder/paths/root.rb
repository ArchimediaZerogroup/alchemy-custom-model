module Alchemy::Custom::Model::ElFinder
  module Paths
    class Root < Base

      def is_root?
        true
      end

      def with_sub_dirs?
        true
      end


      def children(with_directory = true)
        [
            Images.new(@root, 'images', volume: @volume),
            Files.new(@root, 'files', volume: @volume)
        ]
      end

    end
  end
end

