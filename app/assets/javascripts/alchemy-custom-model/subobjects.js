(function ($) {

    $.fn.subobjects = function (options) {

        var options = $.extend(options, {});


        function maximizza(row) {
            var last_element = $(row).find(".fields").find(".input").not(".hidden").last()[0];
            var height = $(last_element).offset().top - row.offset().top;
            row.height(height + $(last_element).height());
        }


        function minimizza(row) {

            var first_element = $(row).find(".fields").find(".input").not(".hidden").first()[0];
            var height = $(first_element).offset().top - row.offset().top;
            row.height(height + $(first_element).height());
        }


        return this.each(function (index, element) {
            var subObjContainer = $(this).find(".sub_objects_container")[0];

            $(subObjContainer).nested_attributes_sortable({field: '.sortable_field'});

            var buttonAdd = $(this).find(".add").get(0);
            $(buttonAdd).on("click", function (event) {
                event.preventDefault();
                var url_partial = $(buttonAdd).data("url");
                var element_to_load = $(buttonAdd).data("to-load");

                $.ajax({
                    url: url_partial,
                    dataType: "html",
                    method: "GET",
                    success: function (data, textStatus, jqXHR) {
                        var to_load = $(data).find(element_to_load);
                        var to_load_id = $(to_load).last().next("input");
                        $(to_load).removeClass("sample");
                        $(subObjContainer).append($(to_load).last());
                        $(subObjContainer).append(to_load_id);

                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        console.error(errorThrown)
                    }
                });
            });


            var buttonMaximizeAll = $(this).find(".maximize_all").get(0);
            $(buttonMaximizeAll).on("click", function (event) {
                event.preventDefault();
                $(subObjContainer).find(".subobject_row:not('.sample')").each(function (index, element) {
                    maximizza($(element));
                });
            });


            var buttonMinimizeAll = $(this).find(".minimize_all").get(0);
            $(buttonMinimizeAll).on("click", function (event) {
                event.preventDefault();
                $(subObjContainer).find(".subobject_row:not('.sample')").each(function (index, element) {
                    minimizza($(element));
                });
            });


            $(this).on('click', ".subobject_row .remove", function (event) {
                event.preventDefault();
                var buttonRemove = event.target

                var toHide = $(this).closest(".subobject_row");
                var destroyField = $(this).find("input")[0];
                $(destroyField).val(true);
                $(toHide).hide(500);


            });

            $(this).on('click', ".subobject_row .minimize", function (event) {
                event.preventDefault();
                minimizza($(this).closest(".subobject_row"));
            })

            $(this).on('click', ".subobject_row .maximize", function (event) {
                event.preventDefault();
                maximizza($(this).closest(".subobject_row"));
            });


        });
    }

})(jQuery);

