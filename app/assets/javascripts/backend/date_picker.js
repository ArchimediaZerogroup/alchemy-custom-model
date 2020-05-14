$(document).on("page:change turbolinks:load",function(){

    $("input[data-alchemy-datepicker-type]").each(function(index,element){
        var  type = $(this).data('alchemy-datepicker-type');
        var options = {
            locale: Alchemy.locale.slice(0, 2),
            altInput: true,
            altFormat: Alchemy.t("formats."+type),
            altInputClass: "",
            enableTime: /time/.test(type),
            noCalendar: type == "time",
            time_24hr: Alchemy.t("formats.time_24hr"),

        };

        $(this).flatpickr(options);



    })



});