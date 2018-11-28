#= require 'alchemy/alchemy.element_editors'



window.CustomProxedElementEditor = $.extend {}, Alchemy.ElementEditors


$.extend window.CustomProxedElementEditor,
  init: (selector = "#element_area")->
    @element_area = $(selector)
    @bindEvents()

    @initialize_tinymce()
    return

  initialize_tinymce: ()->
    ids = []
    @element_area.find('.has_tinymce').each (i, e)->
      ids.push($(e).attr("id").match(/[0-9]+/)[0])
    Alchemy.Tinymce.init(ids)


# disattivazione del check di reload pagina
$(document).on 'submit', '.simple_form.alchemy', (e)=>
  window.onbeforeunload = null;
