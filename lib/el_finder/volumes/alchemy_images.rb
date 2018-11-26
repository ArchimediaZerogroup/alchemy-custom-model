module ElFinder
  module Volumes
    class AlchemyImages < ElFinder::Volumes::Alchemy

      def initialize(options = {root: '/images', name: I18n.t("elfinder.alchemy_images.volume"), id: 'alchemy_library_images', url: '/'})
        super
      end

      def files(target = '.')
        super(root_path)
      end

      def decode(hash)
        super do |path|
          ElFinder::Paths::Image.new(@root, path, volume: self)
        end
      end

      def upload(target, upload)
        super do |file|
          img = ::Alchemy::Picture.new(
              image_file: file
          )
          img.name = img.humanized_name
          img.save
          root_path.build_file_path(img)
        end
      end

      def search(type:, q:)

        super do
          search_query_build(klass: ::Alchemy::Picture, type: type, q: q, mime_attribute: :file_mime_type)
        end

      end

      def disabled_commands

        super + ['rm']

      end

      def duplicate(t)

        new_path = Rails.root.join('tmp', "copy_#{File.basename(t.name)}")

        FileUtils.cp(t.file.path, new_path)

        img = ::Alchemy::Picture.new(
            image_file: new_path
        )
        img.name = img.humanized_name
        img.save
        root_path.build_file_path(img)
      end

      def duplicable?(target)
        true
      end


      def root_path
        ElFinder::Paths::Images.new(@root, '.', volume: self)
      end

    end
  end
end
