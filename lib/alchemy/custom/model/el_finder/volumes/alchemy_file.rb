module Alchemy::Custom::Model::ElFinder
  module Volumes
    class AlchemyFile < Base

      def initialize(options = {root: '/alchemy_library', name: 'Alchemy Library', id: 'alchemy_library', url: '/'})
        super
      end


      def cwd(target = nil)

        target = Paths::Root.new(@root) if target.nil?

        Rails.logger.debug {"CWD:#{target.inspect} "}
        path_info(target)

      end

      def decode(hash)
        super do |path|
          case path.to_s
          when 'images'
            Paths::Images.new(@root, path, volume: self)
          when 'files'
            Paths::Files.new(@root, path, volume: self)
          when /images\/*/
            Paths::Image.new(@root, path, volume: self)
          when /files\/*/
            Paths::File.new(@root, path, volume: self)
          when @root, '.'
            Paths::Root.new(@root, path, volume: self)
          else
            Rails.logger.debug {"PATH BASE:#{path}"}
            if block_given?
              Rails.logger.debug {"YIELDING:#{self.class.name}"}
              yield(path)
            else
              Paths::Base.new(@root, path, volume: self)
            end
          end
        end
      end

      def path_info(target)
        is_dir = target.directory?
        mime = target.mime_type
        name = @name if target.is_root?
        name ||= target.name

        dirs = 0
        if is_dir
          # check if has sub directories
          dirs = 1 if target.with_sub_dirs?
        end

        size = 0
        unless is_dir
          size = target.size
        end

        result = {
            name: name,
            hash: encode(target.path.to_s),
            mime: mime,
            ts: target.mtime.to_i,
            size: size,
            dirs: dirs,
            read: 1,
            write: 1,
            locked: 0,
            class: target.class.name,
            tmb: nil,
            global_id: target.global_id
        }

        result = target.full_fill_paylod(result)

        if target.is_root?
          result[:volumeid] = "#{@id}_"
        else
          result[:phash] = encode(target.dirname.path.to_s)
        end

        result
      end

      def files(target = '.')
        Rails.logger.debug {"FILES PER : #{target.inspect}"}
        unless target.is_a?(Paths::Base)
          if target == '.'
            target = Paths::Root.new(@root, '.', volume: self)
          else
            Rails.logger.debug {target.inspect}
            target = Pathname.new(@root, target, volume: self)
          end
        end

        #Elenco tutte le cartelle
        files = target.children.map {|p| path_info(p)}

        #inserisco sempre anche il padre delle cartelle
        files << cwd(target)
        files
      end

      def pathname(target)
        target.fisical_path
      end

      def upload(target, upload)
        response = {}
        select = []
        added = []
        upload.to_a.each do |file|
          if file.respond_to?(:tempfile)
            the_file = file.tempfile
          else
            the_file = file
          end
          if upload_max_size_in_bytes > 0 && File.size(the_file.path) > upload_max_size_in_bytes
            response[:error] ||= "Some files were not uploaded"
            response[:errorData][@options[:original_filename_method].call(file)] = 'File exceeds the maximum allowed filesize'
          else

            dst = yield(file)

            select << encode(dst)
            added << path_info(dst)
          end
        end
        response[:select] = select unless select.empty?
        response[:added] = added unless added.empty?


        response
      end


      ##
      # Copia un file di alchemy in questo volume
      #
      # @param [ElFinder::Paths::Base] src
      # @return [ElFinder::Paths::Base]
      def copy(src)
        raise 'Non si può copiare nella cartella di alchemy'
      end

      ##
      # Ricerca nel volume
      # @param [String] type tipo di ricerca
      # @param [String] q query di ricerca
      def search(type:, q:)
        query_search = yield
        query_search.uniq.collect do |p|
          path_info(root_path.build_file_path(p))
        end
      end

      def rm(target)
        raise "To Implement"
      end

      def upload_max_size_in_bytes
        999999999
      end

      def duplicable?(target)
        false
      end

      private

      ##
      # Costruisce la query di ricerca
      #
      # @param [ActiveRecord::Base] klass
      # @param [String] type tipo di ricerca
      # @param [String] q query di ricerca
      # @param [Symbol] mime_attribute campo da usare per la ricerca del mime
      def search_query_build(klass:, type:, q:, mime_attribute:)
        case type
        when 'AlchemyTags'
          klass.tagged_with(q)
        when 'mimes'
          klass.where(mime_attribute => q)
        when 'full_search'
          ransack_query = "#{klass.searchable_alchemy_resource_attributes.join('_or_')}_cont"
          klass.ransack(ransack_query.to_sym => q).result
        else
          klass.none
        end
      end


    end
  end
end
