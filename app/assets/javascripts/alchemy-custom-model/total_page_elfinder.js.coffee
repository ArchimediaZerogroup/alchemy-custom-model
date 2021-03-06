$ ->
  if($('#elfinder').length>0)
    datas = $('#elfinder').data()

    elf = new ElFinderConfigurator(
      mode: 'single_selection',
      volumes: datas['elfinderVolumes']
    )

    elf.once 'file_select', (file,fm)->
      parent.tinymce.activeEditor.windowManager.getParams().oninsert(file, fm);
      parent.tinymce.activeEditor.windowManager.close();

    elf.start($('#elfinder'))

