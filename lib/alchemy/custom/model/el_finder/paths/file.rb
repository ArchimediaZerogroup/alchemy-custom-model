module Alchemy::Custom::Model::ElFinder
  module Paths
    class File < ActiveRecordReference

      def full_fill_paylod(payload)
        payload[:original_url] = ::Alchemy::Engine.routes.url_helpers.download_attachment_path(id: active_record_instance.id, name: active_record_instance.slug)
        payload
      end


      def active_record_class
        ::Alchemy::Attachment
      end


      def global_id
        active_record_instance.to_signed_global_id.to_s
      end

    end
  end
end

