module Alchemy::Custom::Model::Admin::BaseHelper


  def base_form_container
    content_tag :div, class: "base_form_container #{controller_name}" do
      yield
    end
  end

  def rich_text_editor(form, field)

    editor_idenfier = "#{field}_#{form.object_id}"

    bf = ActiveSupport::SafeBuffer.new
    bf << form.input(field) do
      content_tag(:div, class: 'tinymce_container') do
        form.text_area field, class: 'has_tinymce', id: "tinymce_#{editor_idenfier}"
      end
    end

    bf << content_tag(:script, :type => "text/javascript") do
      raw "(function(){
          CustomTinyMce.initEditor('#{editor_idenfier}')
          })();
           "
    end

    bf


  end


  def single_image_input(form, field)

    form.input(field) do
      content_tag(:div, class: "elfinder_picture_thumbnail") do
        bf = ActiveSupport::SafeBuffer.new

        component_id = SecureRandom.hex(10)
        component_id_image = "#{component_id}_image"

        ref_id = nil

        unless form.object.send(field).blank?
          ref_id = form.object.send(field).to_signed_global_id.to_s
        end

        bf << form.hidden_field(field, id: component_id, value: ref_id)

        image_path = no_image_path = image_url("no_image.png")

        image_path = form.object.send(field).image_file.thumb("100x100#").url if form.object.send(field) and form.object.send(field).image_file_stored?

        bf << content_tag(:div, image_tag(image_path, id: component_id_image, class: "picture_image"))

        bf << content_tag(:div, class: "edit_images_bottom") do

          bf2 = ActiveSupport::SafeBuffer.new

          bf2 << link_to("#", class: 'open_el_finder',
                         title: t("elfinder.edit_image_button"),
                         data: {
                           "elfinder-mode": 'single_selection',
                           "elfinder-target": "##{component_id}",
                           "elfinder-thumb-target": "##{component_id_image}",
                           "elfinder-volumes": 'AlchemyImages'
                         }) do
            fa_icon("file-image")
          end

          bf2 << link_to("#", class: 'clear_selection',
                         title: t("elfinder.clear_image_button"),
                         data: {
                           "clearfield-target": "##{component_id}",
                           "clearfield-thumb-target": "##{component_id_image}",
                           "clearfield-thumb-target-replace": no_image_path
                         }) do
            fa_icon("times")
          end

          bf2
        end

        bf

      end
    end


  end


  def mime2class(mimeType)
    prefix = 'elfinder-cwd-icon-'
    mime = mimeType.downcase
    #     isText = this.textMimes[mime]
    #
    mime = mime.split('/')
    # if (isText) {
    #   mime[0] += ' ' + prefix + 'text';
    # }

    prefix + mime[0] + (mime[1] ? ' ' + prefix + mime[1].gsub(/(\.|\+)/, '-') : '')
  end


  def single_attachment_input(form, field)
    form.input(field) do
      content_tag(:div, class: "elfinder_attachment") do
        bf = ActiveSupport::SafeBuffer.new

        component_id = SecureRandom.hex(10)

        ref_id = nil
        mime_class = ''

        unless form.object.send(field).blank?
          ref_id = form.object.send(field).to_signed_global_id.to_s
          mime_class = "elfinder-cwd-icon #{mime2class(form.object.send(field).file_mime_type)}"
        end

        bf << form.hidden_field(field, id: component_id, value: ref_id)

        id_icone = "#{component_id}_mime_icon"

        bf << content_tag(:div, class: 'container_icon_container') do
          content_tag(:div, nil, id: id_icone,
                      class: mime_class)
        end

        bf << content_tag(:div, class: "edit_file_bottom") do

          bf2 = ActiveSupport::SafeBuffer.new

          bf2 << link_to("#", class: 'open_el_finder',
                         title: t("elfinder.edit_attachment_button"),
                         data: {
                           "elfinder-mode": 'single_selection',
                           "elfinder-target": "##{component_id}",
                           "elfinder-mime_icon_updater": "##{id_icone}",
                           "elfinder-volumes": 'AlchemyFiles'
                         }) do
            fa_icon("file")
          end

          bf2 << link_to("#", class: 'clear_selection',
                         title: t("elfinder.clear_attachment_button"),
                         data: {
                           "clearfield-target": "##{component_id}",
                           "clearfield-icon": "##{id_icone}"
                         }) do
            fa_icon("times")
          end

          bf2
        end

        bf

      end
    end
  end


  def base_container
    content_tag :div, class: "base_container #{controller_name}" do
      yield
    end
  end

  def render_obj obj, field
    case field
    when :product_category_id
      obj.product_category.try(:name)
    when :visible
      if obj.visible?
        fa_icon("check")
      end
    else
      obj.send field
    end
  end

  def gallery_item(&block)


    content_tag(:div) do
      bf = ActiveSupport::SafeBuffer.new

      bf << capture(&block)

      bf

    end


  end

  ##
  # Costruisce il necessario per la generazione della struttura della gallery e per selezione ed upload immagini
  #
  # @param [FormBuilder] form
  # @param [Symbol] field
  # @param [String] partial_url         url da richiamare ogni volta che avviene una modifica nell'elenco dei files
  #                                     della gallery
  # @param [String] partial_identifier  selettore css da utilizzare per fare il replace e la ricerca del contenuto
  #                                     trovato con url
  # @param [Array] tags                 Array di stringhe identificanti i tags da aggiungere ad ogni immagine caricata
  #                                     direttamente nel volume legato a questo componente
  #
  def gallery_input(form, field, partial_url:, partial_identifier:, tags: [])

    return '' unless form.object.persisted?


    obj_cls = form.object.class
    hint_helper = ''
    chiave_i18n = "#{obj_cls.i18n_scope}.attributes.#{obj_cls.model_name.i18n_key}.#{field}_hint"
    hint_helper = hint_with_tooltip(t(chiave_i18n), icon: 'question-circle') if I18n.exists?(chiave_i18n)

    form.input(field, label: obj_cls.human_attribute_name(field).html_safe + hint_helper) do
      content_tag(:div, class: 'elfinder_picture_gallery') do
        bf2 = ActiveSupport::SafeBuffer.new

        container_images = SecureRandom.hex

        bf2 << content_tag(:div, class: 'blk_container_immagini', id: container_images) do
          bf = ActiveSupport::SafeBuffer.new

          component_id = SecureRandom.hex(10)

          bf << form.fields_for(field) do |join_record_form|
            render(layout: 'gallery_item', locals: {picture: join_record_form.object.picture}) do

              join_record_form.hidden_field :position, class: 'gallery_position_counter'

            end
          end

          bf << content_tag(:div, class: 'gallery_item_blk') do
            link_to("#", class: 'open_el_finder', data: {
              "elfinder-mode": 'multiple_selection',
              "elfinder-target_upgrader": partial_url,
              "elfinder-target": partial_identifier,
              "elfinder-volumes": 'AlchemyImages,GalleryVolume',
              "elfinder-volumes_cfgs": Base64.strict_encode64({
                                                                "GalleryVolume": {
                                                                  volume: 'ComponentAttribute',
                                                                  attribute: field,
                                                                  object: form.object.to_signed_global_id.to_s,
                                                                  file_link_ref: 'picture',
                                                                  tags: tags
                                                                }
                                                              }.to_json)
            }) do
              fa_icon("images")
            end
          end


          bf

        end

        bf2 << content_tag(:script, :type => "text/javascript") do
          raw "(function(){
            $('##{container_images}').nested_attributes_sortable({field:'.gallery_position_counter'});
          })();
           "
        end

        bf2
      end
    end


  end


  # @param [Symbol] label per la form
  # @param [FormBuilder] form
  # @param [Symbol] field identifica la relazione
  # @param [Object] to_load TODO documentare
  # @param [Object] url_partial url da dove caricare il partial da dove arriva un nuovo blocco html contenente questo subelemento
  # @param [Object] active_record_modifier Proc chiamata durante l'esecuzione della query per la selezione degli elementi,
  #                                        sovrascrivere e ritornare un ActiveRecord::Relation
  def subobject(label, form, field, to_load:, url_partial:, active_record_modifier: ->(relation) {relation})
    content_tag(:fieldset, class: :subobjects) do
      sb = ActiveSupport::SafeBuffer.new

      sb << content_tag(:legend, label)
      sb << content_tag(:div, class: "sub_objects_container sub_object_#{field}") do
        sub_obj = ActiveSupport::SafeBuffer.new

        active_record_modifier.call(form.object.send(field)).each_with_index do |subo, index|

          sub_obj << form.simple_fields_for(field, subo, child_index: subo.new_record? ? Time.now.getutc.strftime("%9N") : index) do |subform|

            form_attrs = subform.object.attributes.reject do |attr, val|
              attr == form.object.class.reflect_on_association(field).foreign_key
            end
            is_sample = form_attrs.all? {|attr, val| val.blank?}

            content_tag(:div, id: "#{subform.object.class.name.demodulize.underscore}_#{subform.object.id}", class: "subobject_row row_#{field.to_s.singularize} #{"sample" if is_sample}") do

              form_html = ActiveSupport::SafeBuffer.new


              form_html << content_tag(:div, class: "buttons toolbar_button") do
                button_bar = ActiveSupport::SafeBuffer.new
                button_bar << content_tag(:div, class: "button_with_label maximize") do
                  link_to "#", class: "icon_button" do
                    fa_icon "window-maximize"
                  end
                end

                button_bar << content_tag(:div, class: "button_with_label minimize") do
                  link_to "#", class: "icon_button" do
                    fa_icon "window-minimize"
                  end
                end

                button_bar << content_tag(:div, class: "button_with_label remove") do
                  content_tag(:span, class: "icon_button") do
                    icon_button = ActiveSupport::SafeBuffer.new
                    icon_button << fa_icon("trash", title: t(:remove))
                    icon_button << subform.input(:_destroy, as: :hidden, input_html: {class: "destroy"})
                    icon_button
                  end

                end


                button_bar
              end
              form_html << content_tag(:div, class: "fields") do
                yield subform
              end


              form_html
            end
          end


        end

        #sub_obj << content_for(:"sample_#{field}")
        sub_obj
      end
      sb << content_tag(:div, class: "buttons") do
        buttons = ActiveSupport::SafeBuffer.new
        buttons << button_tag(type: "button", class: "minimize_all", title: t(:minimize_all)) do
          fa_icon("window-minimize")
        end
        buttons << button_tag(type: "button", class: "maximize_all", title: t(:maxzimize_all)) do
          fa_icon("window-maximize")
        end
        buttons << button_tag(type: "button", class: "add", title: t(:title_add), data: {to_load: to_load, url: url_partial}) do
          fa_icon("plus")
        end
        buttons
      end
      sb
    end


  end


  def check_presence_polymorphic_path(record_or_hash_or_array, options = {})
    begin
      polymorphic_path record_or_hash_or_array, options
      true
    rescue NoMethodError
      false
    end
  end


end