module Alchemy::Custom::Model::ElFinder
  module Volumes
    class AlchemyFiles < ElFinder::Volumes::AlchemyFile

      def initialize(options = {root: '/files', name: 'Alchemy Library - Files', id: 'alchemy_library_files', url: '/'})
        super
      end

      def files(target = '.')
        super(root_path)
      end

      def decode(hash)
        super do |path|
          ElFinder::Paths::File.new(@root, path, volume: self)
        end
      end

      def upload(target, upload)
        super do |file|
          f = ::Alchemy::Attachment.create(
              file: file
          )
          root_path.build_file_path(f)
        end
      end

      def search(type:, q:)

        super do
          search_query_build(klass: ::Alchemy::Attachment, type: type, q: q, mime_attribute: :file_mime_type)
        end

      end

      def disabled_commands

        super + ['rm']

      end

      private

      def root_path
        ElFinder::Paths::Files.new(@root, '.', volume: self)
      end

    end
  end
end

