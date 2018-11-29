module Alchemy::Custom::Model
  module ElFinder
    module Volumes
      class Base

        include TranslationScope

        attr_reader :id, :name, :root, :url

        def initialize(options)
          [:id, :name, :root, :url].each do |opt|
            raise(ArgumentError, "Missing required #{opt} option") unless options.key?(opt)
          end

          @id = options[:id]
          @name = options[:name]
          @root = options[:root]
          @url = options[:url]

          # @options = {
          #   upload_file_mode: 0644,
          #   original_filename_method: lambda {|file| file.original_filename.respond_to?(:force_encoding) ? file.original_filename.force_encoding('utf-8') : file.original_filename}
          # }
        end

        def contains?(hash)
          hash.start_with?("#{@id}_")
        end

        def cwd(target = '.')
#       {
#     "name"   : "Images",             // (String) name of file/dir. Required
#     "hash"   : "l0_SW1hZ2Vz",        // (String) hash of current file/dir path, first symbol must be letter, symbols before _underline_ - volume id, Required.
#     "phash"  : "l0_Lw",              // (String) hash of parent directory. Required except roots dirs.
#     "mime"   : "directory",          // (String) mime type. Required.
#     "ts"     : 1334163643,           // (Number) file modification time in unix timestamp. Required.
#     "date"   : "30 Jan 2010 14:25",  // (String) last modification time (mime). Depricated but yet supported. Use ts instead.
#     "size"   : 12345,                // (Number) file size in bytes
#     "dirs"   : 1,                    // (Number) Only for directories. Marks if directory has child directories inside it. 0 (or not set) - no, 1 - yes. Do not need to calculate amount.
#     "read"   : 1,                    // (Number) is readable
#     "write"  : 1,                    // (Number) is writable
#     "locked" : 0,                    // (Number) is file locked. If locked that object cannot be deleted and renamed
#     "tmb"    : 'bac0d45b625f8d4633435ffbd52ca495.png' // (String) Only for images. Thumbnail file name, if file do not have thumbnail yet, but it can be generated than it must have value "1"
#     "alias"  : "files/images",       // (String) For symlinks only. Symlink target path.
#     "thash"  : "l1_c2NhbnMy",        // (String) For symlinks only. Symlink target hash.
#     "dim"    : "640x480"             // (String) For images - file dimensions. Optionally.
#     "volumeid" : "l1_"               // (String) Volume id. For root dir only.
# }
# {
#   name: @name,
#   hash: encode('.'),
#   mime: 'directory',
#   ts: File.mtime(@root).to_i,
#   size: 0,
#   dirs: 0,
#   read: 1,
#   write: 1,
#   locked: 0,
#   volumeid: "#{@id}_"
# }
          path_info(ElFinder::Pathname.new(@root, target))
        end

        # def path_info(target)
        #   is_dir = File.directory?(target.realpath)
        #   mime = is_dir ? 'directory' : ElFinder::MimeType.for(target.realpath)
        #   name = @name if target.is_root?
        #   name ||= target.basename.to_s
        #
        #   dirs = 0
        #   if is_dir
        #     # check if has sub directories
        #     dirs = 1 if Dir[File.join(target.realpath, '*/')].count > 0
        #   end
        #
        #   size = 0
        #   unless is_dir
        #     size = File.size(target.realpath)
        #   end
        #
        #   result = {
        #     name: name,
        #     hash: encode(target.path.to_s),
        #     mime: mime,
        #     ts: File.mtime(target.realpath).to_i,
        #     size: size,
        #     dirs: dirs,
        #     read: 1,
        #     write: 1,
        #     locked: 0
        #   }
        #   if target.is_root?
        #     result[:volumeid] = "#{@id}_"
        #   else
        #     result[:phash] = encode(target.dirname.path.to_s)
        #   end
        #
        #   result
        # end


        def decode(hash)
          hash = hash.slice(("#{@id}_".length)..-1) if hash.start_with?("#{@id}_")
          hash = hash.tr('-_.', '+/=')
          # restore missing '='
          len = hash.length % 4
          hash += '==' if len == 1 or len == 2
          hash += '=' if len == 3
          path = Base64.strict_decode64(hash)

          if block_given?
            yield path
          else
            ElFinder::Pathname.new(@root, path)
          end

        end

        def encode(path)
          # creates hash for the path
          # path = ElFinder::Pathname.new(@root, path).path.to_s
          hash = Base64.strict_encode64(path)
          hash.tr!('+/=', '-_.')
          hash.gsub!(/\.+\Z/, '')
          "#{@id}_#{hash}"
        end

        # def files(target = '.')
        #   target = ElFinder::Pathname.new(@root, target)
        #   files = []
        #   # files = target.children.map {|p| path_info(p)}
        #   files << cwd(target)
        #   files
        # end

        def pathname(target)
          raise "Absolute Path for file"
        end

        ##
        # Elenco comandi disabilitati
        def disabled_commands
          []
        end

      end
    end
  end
end
