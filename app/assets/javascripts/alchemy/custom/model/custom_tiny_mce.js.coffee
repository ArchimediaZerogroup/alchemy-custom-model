#= require 'lodash/lodash.js'

#duplichiamo la classe
class CustomTinyMce extends Alchemy.Tinymce


  #per come è stato fatto dobbiamo estendere la classe tramite i metodi che usa jquery
$.extend CustomTinyMce,


#  {
#    skin: 'alchemy',
#    width: 'auto',
#    resize: true,
#    autoresize_min_height: '105',
#    autoresize_max_height: '480',
#    menubar: false,
#    statusbar: true,
#    toolbar: [
#      'bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen',
#      'pastetext charmap hr | undo redo | alchemy_link unlink anchor | code'
#    ],
#    fix_list_elements: true,
#    convert_urls: false,
#    entity_encoding: 'raw',
#    paste_as_text: true,
#    element_format: 'html',
#    branding: false
#  }

  getDefaultConfig: (id) ->
    configs = $.extend true, {}, Alchemy.Tinymce.getDefaultConfig(id)
    configs.init_instance_callback = @initInstanceCallback

    configs.plugins += ",image"
    configs.toolbar[1] += ' | link image'
    configs.file_picker_callback = (callback, value, meta)->

      volumes = []

      if (meta.filetype == 'file')
        volumes.push('AlchemyFiles');


      #            // Provide image and alt text for the image dialog
      if (meta.filetype == 'image')
        volumes.push('AlchemyImages');

      tinymce.activeEditor.windowManager.open({
        file: Routes.admin_elfinder_ui_path(volumes:volumes), #// use an absolute path!
        title: 'elFinder 2.1',
        width: 900,
        height: 450,
        resizable: 'yes'
      }, {
        oninsert: (file, fm)->
#            // URL normalization
          url = fm.convAbsUrl(file.url);

          #            // Make file info
          info = file.name + ' (' + fm.formatSize(file.size) + ')';

          #            // Provide file and text for the link dialog
          if (meta.filetype == 'file')
            callback(file.original_url, {text: info, title: info})


          #            // Provide image and alt text for the image dialog
          if (meta.filetype == 'image')
            callback(file.original_url, {alt: info})


          #            // Provide alternative source and posted for the media dialog
          if (meta.filetype == 'media')
            callback(url)

          return false;
      });

    return configs



  initInstanceCallback: (editor) ->
    $this = $("##{editor.id}")
    element = $this.closest('.tinymce_container')
    element.on 'parent_stop_sorted', _.debounce(()=>
      id = editor.getElement().id.replace(/^tinymce_/, '')
      editor.remove();
      CustomTinyMce.initEditor(id)
    , 100)
    element.find('.spinner').remove()


@CustomTinyMce = CustomTinyMce