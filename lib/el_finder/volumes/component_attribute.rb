module ElFinder
  module Volumes
    class ComponentAttribute < ElFinder::Volumes::Alchemy

      attr_accessor :record, :attribute, :file_link_ref, :tags

      ##
      # Elenco opzioni da utilizzare per la configurazione
      #  - attribute      = relazione dell'oggetto a cui si riferisce il collegamento del volume (la join table per esempio)
      #  - object         = oggetto identificato con un global_id signed
      #  - file_link_ref  = rispetto ad un'istanza della relazione come fare a trovare il valore del record alchemy(Picture o Attachment),
      #                     nel caso avessimo più metodi da chiamare possiamo spezzarlo con il . fra un metodo e l'altro
      #                     il programma dovrà spezzare per il . e usare dig per chiamare i valori definitivi
      #  - tags           = Array di stringhe per i tag da associare direttamente ai files caricati
      def initialize(opts = {})

        self.record = GlobalID::Locator.locate_signed opts.delete(:object)
        self.attribute = opts.delete(:attribute)
        self.file_link_ref = opts.delete(:file_link_ref)
        self.tags = opts.delete(:tags) {[]}

        identificativo_volume = "component_#{self.attribute}" #"_#{record.id}"

        # identificativo_volume='test_semplice_nome'

        # unless self.record.send(self.attribute).klass.new.respond_to?(:alchemy_file_instance)
        #   raise "Attenzione, non è stata impostata la relazione per collegare la join table con l'elemento il record di alchemy [:alchemy_file_instance]"
        # end

        super({root: "/#{identificativo_volume}", name: 'Elementi associati', id: "#{identificativo_volume}", url: '/'})
      end

      def files(target = '.')
        super(root_path)
      end

      def root_path
        ElFinder::Paths::ComponentFiles.new(@root, '.', volume: self)
      end

      def copy(src)
        new_rec = associate_record_to_active_instance(src.active_record_instance)
        root_path.build_file_path(new_rec)
      end

      def decode(hash)
        super do |path|
          ElFinder::Paths::ComponentFile.new(@root, path, volume: self)
        end
      end

      def upload(target, upload)
        super do |file|

          if remote_alchemy_relation == ::Alchemy::Picture
            img = ::Alchemy::Picture.new(
                image_file: file
            )
            img.name = img.humanized_name
            img.save

            #lego l'immagine ora al prodotto
            new_rec = associate_record_to_active_instance(img)

            root_path.build_file_path(new_rec)
          else
            raise "TO override"
          end
        end
      end


      ##
      # Indica l'oggetto finale a cui viene legata la join table del componente
      def remote_alchemy_relation
        attribute_class.reflect_on_association(:alchemy_file_instance).klass
      end

      def attribute_class
        self.record.send(self.attribute).klass
      end

      def search(type:, q:)

        query_search = search_query_build(klass: remote_alchemy_relation, type: type, q: q, mime_attribute: :image_file_format)

        self.record.send(self.attribute).joins(:alchemy_file_instance).merge(query_search).uniq.collect do |p|
          path_info(root_path.build_file_path(p))
        end

      end


      def duplicate(t)
        new_path = Rails.root.join('tmp', "copy_#{File.basename(t.name)}")

        FileUtils.cp(t.file.path, new_path)

        img = ::Alchemy::Picture.new(
            image_file: new_path
        )
        img.name = img.humanized_name
        img.save

        new_rec = associate_record_to_active_instance(img)
        root_path.build_file_path(new_rec)
      end


      def duplicable?(target)
        remote_alchemy_relation == ::Alchemy::Picture
      end

      ##
      # Nel caso del componente, rm vuol dire dissociare il target elementi
      def rm(target)
        target.active_record_instance.destroy
      end

      private

      def associate_record_to_active_instance(rec)
        self.record.class.transaction do
          rec.update_attributes(tag_list: (self.tags + rec.tag_list).flatten.compact)
          self.record.send(self.attribute).create(:alchemy_file_instance => rec)
        end
      end
    end
  end
end
