$.extend Alchemy,
  removePicture: (selector) ->
    $form_field = $(selector)
    $element = $form_field.closest(".element-editor")
    $content = $form_field.closest(".content_editor")
    if $form_field[0]
      $form_field.val ""
      $content.find(".thumbnail_background").html('<i class="icon far fa-image fa-fw"/>')
      Alchemy.setElementDirty $element
    false
