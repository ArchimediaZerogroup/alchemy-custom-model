module ElFinder
  class Connector

    VERSION = 2.1

    # Valid commands to run.
    # @see #run
    VALID_COMMANDS = %w[open tree file paste upload search rm ls dim resize duplicate] #%w[archive duplicate edit extract mkdir mkfile open parents paste ping read rename resize rm tmb upload]

    # Default options for instances.
    # @see #initialize
    DEFAULT_OPTIONS = {
        :mime_handler => ::ElFinder::MimeType,
        # :image_handler => ElFinder::Image,
        :original_filename_method => lambda {|file| file.original_filename.respond_to?(:force_encoding) ? file.original_filename.force_encoding('utf-8') : file.original_filename},
        :disabled_commands => [],
        :allow_dot_files => true,
        :upload_max_size => '50M',
        # :upload_file_mode => 0644,
        # :archivers => {},
        # :extractors => {},
        :home => 'Home',
        :default_perms => {:read => true, :write => true, :rm => true, :hidden => false},
        :perms => [],
        :thumbs => false,
        :thumbs_directory => '.thumbs',
        :thumbs_size => 48,
        :thumbs_at_once => 5,
        # :tree_sub_folders => true, # list sub/sub folders in the tree
    }

    # Initializes new instance.
    # @param [Hash] options Instance options. :url and :root options are required.
    # @option options [String] :url Entry point of ElFinder router.
    # @option options [String] :root Root directory of ElFinder directory structure.
    # @see DEFAULT_OPTIONS
    def initialize(options)
      @options = DEFAULT_OPTIONS.merge(options)

      @options[:disabled_commands] += ['mkdir', 'rename']

      raise(ArgumentError, "Missing required :volumes option") unless @options.key?(:volumes)
      # raise(ArgumentError, "Missing required :url option") unless @options.key?(:url)
      # raise(ArgumentError, "Missing required :root option") unless @options.key?(:root)
      raise(ArgumentError, "Mime Handler is invalid") unless mime_handler.respond_to?(:for)
      # raise(ArgumentError, "Image Handler is invalid") unless image_handler.nil? || ([:size, :resize, :thumbnail].all? {|m| image_handler.respond_to?(m)})

      @volumes = options[:volumes]
      @root = Pathname.new(options[:root])

      @headers = {}
      @response = {}
    end

    # of initialize

    # Runs request-response cycle.
    # @param [Hash] params Request parameters. :cmd option is required.
    # @option params [String] :cmd Command to be performed.
    # @see VALID_COMMANDS
    def run(params)
      @params = params.dup
      @headers = {}
      @response = {}
      @response[:errorData] = {}
      @file = nil

      if VALID_COMMANDS.include?(@params[:cmd])

        if @options[:thumbs]
          @thumb_directory = @root + @options[:thumbs_directory]
          @thumb_directory.mkdir unless @thumb_directory.exist?
          raise(RuntimeError, "Unable to create thumbs directory") unless @thumb_directory.directory?
        end

        @current = @params[:current] ? from_hash(@params[:current]) : nil
        @volume, @target = (@params[:target] and !@params[:target].empty?) ? from_hash(@params[:target]) : [nil, nil]
        if params[:targets]
          @targets = @params[:targets].map {|t| from_hash(t)}
        end

        send("_#{@params[:cmd]}")
      else
        invalid_request
      end

      @response.delete(:errorData) if @response[:errorData].empty?

      return @headers, @response, @file
    end

    # of run

    #
    def to_hash(pathname)
      # note that '=' are removed
      Base64.urlsafe_encode64(pathname.path.to_s).chomp.tr("=\n", "")
    end

    # of to_hash

    #
    def from_hash(hash)
      volume = @volumes.find {|v| v.contains?(hash)}
      if volume
        [volume, volume.decode(hash)]
      else
        @response[:error] = 'errFileNotFound'
        nil
      end
      # restore missing '='
      #   len = hash.length % 4
      #   hash += '==' if len == 1 or len == 2
      #   hash += '='  if len == 3

      #   decoded_hash = Base64.urlsafe_decode64(hash)
      #   decoded_hash = decoded_hash.respond_to?(:force_encoding) ? decoded_hash.force_encoding('utf-8') : decoded_hash
      #   pathname = @root + decoded_hash
      # rescue ArgumentError => e
      #   if e.message != 'invalid base64'
      #     raise
      #   end
      #   nil
    end

    # of from_hash

    # @!attribute [w] options
    # Options setter.
    # @param value [Hash] Options to be merged with instance ones.
    # @return [Hash] Updated options.
    def options=(value = {})
      value.each_pair do |k, v|
        @options[k.to_sym] = v
      end
      @options
    end

    # of options=

    ################################################################################

    protected

    def _file
      if @volume && @target
        path = @volume.pathname(@target)
        @file = {path: path}
      end
    end

    def _search
      type = @params.delete(:type) {"full_search"}
      q = @params.delete(:q)
      if @params[:mimes]
        type = 'mimes'
        q = @params[:mimes]
      end

      @response[:files] = @volume.search(type: type, q: q)

    end

    ##
    # Funzione lanciata praticamente all'upload dei file, dato che non abbiamo problemi di duplicati
    # dato che sono tutti in database, inviamo sempre un vuoto
    # nel caso dobbiamo implementare invece questo: https://github.com/Studio-42/elFinder/wiki/Client-Server-API-2.1#ls
    def _ls
      @response[:list] = []
    end

    #
    def _open(volume = nil, target = nil, payload: {})
      if @params[:init]
        _open_init
        return
      end

      volume ||= @volume
      target ||= @target

      if volume.nil?
        _open(@volumes[0], nil, payload: payload)
        return
      end

      if target.nil?
        _open(volume, '.', payload: payload)
        return
      end

      # if perms_for(target)[:read] == false
      #   @response[:error] = 'Access Denied'
      #   return
      # end

      if target.file?
        command_not_implemented
      elsif target.directory?
        @response[:cwd] = volume.cwd(target)
        @response[:files] = volume.files(target)
        @response.merge!(payload)

        # @response[:cdc] = target.children.
        #   reject{ |child| perms_for(child)[:hidden]}.
        #   sort_by{|e| e.basename.to_s.downcase}.map{|e| cdc_for(e)}.compact

        # if @params[:tree]
        #   @response[:tree] = {
        #     :name => @options[:home],
        #     :hash => to_hash(@root),
        #     :dirs => tree_for(@root),
        #   }.merge(perms_for(@root))
        # end
        @response[:options] = {}
        if @params[:init]
          @response = init_request(@response, volume: volume)
        else
          #se non siamo in init, allora inseriamo l'elenco dei comandi che il volume aperto non supporta
          @response[:options][:disabled] = init_request(@response.dup, volume: volume)[:options][:disabled]
        end

      else
        @response[:error] = "Directory does not exist"
        _open(@root) if File.directory?(@root)
      end

    end

    # of open


    def _dim
      if @target.is_a? ElFinder::Paths::Image
        @response[:dim] = @target.dim
      else
        @response[:error] = "Operazione non supportata"
      end
    end


    def _tree(volume = nil, target = nil)
      volume ||= @volume
      target ||= @target

      @response[:api] = VERSION
      @response[:tree] = volume.tree(target)

    end

    def init_request(payload, volume:)
      payload[:api] = VERSION
      # payload[:disabled] = @options[:disabled_commands]
      payload[:options] = {
          :dotFiles => @options[:allow_dot_files],
          :uplMaxSize => @options[:upload_max_size],
          :uploadMaxConn => -1, #configurazione per cui non deve spezzare in chucks i files
          :archives => [], #@options[:archivers].keys,
          :extract => [], #@options[:extractors].keys,
          :url => @options[:url],
          disabled: @options[:disabled_commands] + volume.disabled_commands
      }

      payload
    end

    def _open_init
      @response[:cwd] = @volumes[0].cwd

      files = []
      @volumes.each {|v| files.concat(v.files)}
      @response[:files] = files
      @response = init_request(@response, volume: @volumes[0])
    end

    # of open_init

    def _paste

      moved_files = []
      @targets.to_a.each do |src_v, src_f|

        #scopro il volume di destinazione
        dst_v, dst_f = from_hash(@params[:dst])

        if dst_v.is_a?(ElFinder::Volumes::ComponentAttribute)
          moved_files << dst_v.copy(src_f)
        else
          @response[:error] ||= 'Copia non consentita'
        end

      end
      @params[:tree] = true

      # dest_vlm = @targets.first[0]
      dest_vlm = from_hash(@params[:dst])[0]

      dest_target = dest_vlm.decode(dest_vlm.encode('.'))

      _open(dest_vlm, dest_target, payload: {moved_files: moved_files.collect {|v| dest_vlm.path_info(v)}})
    end

    # of paste


    def _rm
      @response[:removed] = @targets.to_a.collect do |src_v, src_f|
        src_v.rm(src_f)
        src_v.encode(src_f.path.to_s)
      end
    end

    #
    def _resize
      if @target.is_image?

        file = @target.file
        case @params[:mode]
        when 'resize'
          file = file.thumb("#{@params[:width]}x#{@params[:height]}!")
        when 'crop'
          file = file.thumb("#{@params[:width]}x#{@params[:height]}+#{@params[:x]}+#{@params[:y]}")
        when 'rotate'

          command = []
          command << "-background #{@params[:bg]}" unless @params[:bg].blank?
          command << "-rotate #{@params[:degree]}"

          file = file.convert(command.join(' '))
        else
          @response[:error] = "Mode:#{@params[:mode]} not implemented"
          return
        end
        file = file.convert("-quality #{@params[:quality]}") if @params[:quality].to_i < 100
        @target.file = file
        @target.save

        @response[:changed] = [to_hash(@target)]
        _open(@volume, @volume.root_path)
      else
        @response[:error] = "Unable to resize file. It does not exist"
      end
    end

    # of resize

    def _duplicate

      @targets.each do |v, f|
        unless f.is_image?
          @response[:error] = "#{f.name} non è un'immagine"
          return
        end
      end

      @targets.each do |v, f|
        unless v.duplicable?(f)
          @response[:error] = "#{f.name} non può essere duplicato"
          return
        end
      end

      added = @targets.collect do |v, t|
        v.path_info(v.duplicate(t))
      end

      @response[:added] = added
      # _open(@targets.first[0], @targets.first[0].root_path)
    end

    # of duplicate


    #
    def _upload
      if @volume && @target
        response = @volume.upload(@target, @params[:upload])
        @response.merge!(response)
        # _open(@volume, @target)
      else
        @response[:error] = "errUploadCommon"
      end
      # if perms_for(@current)[:write] == false
      #   @response[:error] = 'Access Denied'
      #   return
      # end
      # select = []
      # @params[:upload].to_a.each do |file|
      #   if file.respond_to?(:tempfile)
      #     the_file = file.tempfile
      #   else
      #     the_file = file
      #   end
      #   if upload_max_size_in_bytes > 0 && File.size(the_file.path) > upload_max_size_in_bytes
      #     @response[:error] ||= "Some files were not uploaded"
      #     @response[:errorData][@options[:original_filename_method].call(file)] = 'File exceeds the maximum allowed filesize'
      #   else
      #     dst = @current + @options[:original_filename_method].call(file)
      #     the_file.close
      #     src = the_file.path
      #     FileUtils.mv(src, dst.fullpath)
      #     FileUtils.chmod @options[:upload_file_mode], dst
      #     select << to_hash(dst)
      #   end
      # end
      # @response[:select] = select unless select.empty?
      # _open(@current)
    end

    # of upload

    private

    def mime_handler
      @options[:mime_handler]
    end

    #
    # def image_handler
    #   @options[:image_handler]
    # end

    #
    def invalid_request
      @response[:error] = "Invalid command '#{@params[:cmd]}'"
    end

    # of invalid_request

    #
    def command_not_implemented
      @response[:error] = "Command '#{@params[:cmd]}' not yet implemented"
    end # of command_not_implemented
  end
end
