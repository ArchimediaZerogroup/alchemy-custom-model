module ElFinder
    module Paths
      class ActiveRecordReference < ElFinder::Paths::Base


        URI_SPACER = '___'

        def file?
          true
        end

        def directory?
          false
        end

        def active_record_class
          raise "ToOverride"
        end

        def active_record_instance=(v)
          @_active_record_instance = v
        end

        def active_record_instance
          return @_active_record_instance if @_active_record_instance
          id = self.path.basename.to_s.split(URI_SPACER).first
          @_active_record_instance = self.active_record_class.find(id)

          # gid = "gid://#{self.path.basename.to_s}"#.split(URI_SPACER)
          # @_active_record_instance = GlobalID::Locator.locate gid# self.active_record_class.find(id)
        end

        def self.file_to_uri(p)
          #p.to_global_id.uri.to_s.gsub(/^gid\:\/\//,'')
          "#{p.id}#{URI_SPACER}"
        end

        def file
          active_record_instance.file
        end

        def fisical_path
          file.path
        end

        delegate :name, :mime_type, :size, to: :file

      end
    end
end