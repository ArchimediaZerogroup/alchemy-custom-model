$ = jQuery

# Adds plugin object to jQuery
$.fn.extend
  nested_attributes_sortable: (options) ->
# Default settings
    settings =
      field: null #campo obbligatorio

    # Merge default settings with options.
    settings = $.extend settings, options

    console.error('field required for nested_attributes_sortable') if settings.field == ''

    return @each ()->
      $(@).sortable(
        update: (event, ui)->
          console.log(arguments);
          $(event.target).find(settings.field).each (i)->
            $(@).val(i)
          $(event.target).find('*').trigger('parent_sorted', event.target);
        stop:(event)->
          $(event.target).find('*').trigger('parent_stop_sorted', event.target);
      );
      $(@).disableSelection();