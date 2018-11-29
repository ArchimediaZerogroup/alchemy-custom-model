module Alchemy::Custom::Model
  module Admin
    class FilesController < Alchemy::Admin::BaseController

      skip_before_action :verify_authenticity_token, :only => ['elfinder']

      def elfinder
        authorize! :usage, Alchemy::Custom::Model::ElFinder

        h, r, f = connector.run(params)

        headers.merge!(h)

        if f.blank?
          render (r.empty? ? {:nothing => true} : {:plain => r.to_json}), :layout => false
        else
          send_file f[:path], disposition: :inline
        end


      end

      def ui
        @volumes = params[:volumes]
        authorize! :ui_usage, Alchemy::Custom::Model::ElFinder
        render layout: false
      end

      private

      def connector


        volumi = []

        if params[:volumes].blank?
          volumi << ElFinder::Volumes::AlchemyFile.new
        else

          volumes = params[:volumes]
          volumes = volumes.split(',') if volumes.is_a? String

          volumes_cfgs = {}
          if params[:volumes_cfgs]
            volumes_cfgs = ActiveSupport::HashWithIndifferentAccess.new(ActiveSupport::JSON.decode(Base64.strict_decode64(params[:volumes_cfgs])))
            Rails.logger.info {"CONFIGURAZIONE_VOLUMI: #{volumes_cfgs.inspect}"}
          end


          volumes.each do |v|

            if volumes_cfgs.key?(v)

              cfgs = volumes_cfgs[v]

              volumi << ElFinder::Volumes.const_get(cfgs.delete(:volume)).new(cfgs)
            else
              volumi << ElFinder::Volumes.const_get(v).new
            end

          end
        end


        ElFinder::Connector.new(
          :root => '/alchemy_library', #File.join(Rails.public_path, 'public'),
          # :url => '/system/elfinder',
          # :perms => {
          #   /^(Welcome|README)$/ => {:read => true, :write => false, :rm => false},
          #   '.' => {:read => true, :write => false, :rm => false}, # '.' is the proper way to specify the home/root directory.
          #   /^test$/ => {:read => true, :write => true, :rm => false},
          #   'logo.png' => {:read => true},
          #   /\.png$/ => {:read => false} # This will cause 'logo.png' to be unreadable.
          #   # Permissions err on the safe side. Once false, always false.
          # },
          # :extractors => {
          #   'application/zip' => ['unzip', '-qq', '-o'], # Each argument will be shellescaped (also true for archivers)
          #   'application/x-gzip' => ['tar', '-xzf'],
          # },
          # :archivers => {
          #   'application/zip' => ['.zip', 'zip', '-qr9'], # Note first argument is archive extension
          #   'application/x-gzip' => ['.tgz', 'tar', '-czf'],
          # },
          # :tree_sub_folders => true,
          #adds {Rails.root}/public/uploads as "root" volume, named "uploads" in the GUI
          :volumes => volumi,
          #[{:id => "root", :name => "uploads", :root => File.join(Rails.root, 'public', 'uploads'), :url => "files/"}],
          :mime_handler => ::ElFinder::MimeType,
          :image_handler => ElFinder::Image,
          :original_filename_method => lambda {|file| file.original_filename.respond_to?(:force_encoding) ? file.original_filename.force_encoding('utf-8') : file.original_filename},
          :disabled_commands => ['mkfile'],
          :allow_dot_files => true,
          :upload_max_size => '50M',
          # :upload_file_mode => 0644,
          :home => 'Home',
          :default_perms => {:read => true, :write => true, :rm => true, :hidden => false},
          :thumbs => false,
          :thumbs_directory => '.thumbs',
          :thumbs_size => 48,
          :thumbs_at_once => 5,
        )
      end

    end
  end
end