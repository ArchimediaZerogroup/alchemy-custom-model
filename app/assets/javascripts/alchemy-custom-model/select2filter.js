(function ($) {

    $.fn.slect2filter = function (options) {

        var options = $.extend({
            elementToFilter: "",
            hideparam: "to-hide-id"
        }, options);

        if (options.elementToFilter === "") {
            throw "select2filter: You have to specify elementToFilter option";
        }


        return this.each(function (index, element) {
            var allOptions = $(options.elementToFilter).find("option");
            if ($(options.elementToFilter).val() == "") {
                $(options.elementToFilter).prop("disabled", true);
            }
            var select = this

            $(this).change(function (event) {

                if ($(element).val() != "") {
                    $(options.elementToFilter).select2("destroy");
                    $(options.elementToFilter).html(allOptions);
                    $(options.elementToFilter).val(null);

                    $(options.elementToFilter).find("option").each(function (index, element) {
                        var selectedValue = $(select).val();
                        if ($(this).val() != "" && $(this).attr("data-" + options.hideparam) != selectedValue) {
                            $(this).remove();
                        }
                    });

                    $(options.elementToFilter).prop("disabled", false);
                    $(options.elementToFilter).select2({
                        //allowClear: true,
                        minimumResultsForSearch: 7,
                        dropdownAutoWidth: true

                    });


                }
            });
        })

    }

})(jQuery);