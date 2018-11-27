$(document).on("'page:change turbolinks:load", function(){
    $(".datepicker-date").datetimepicker({
        scrollInput: false,
        format: "d/m/Y",
        timepicker: false,
        datepicker: true,
        dayOfWeekStart: 0
    })

    $(".datepicker-time").datetimepicker({
        format:'H:i',
        timepicker: true,
        datepicker: false,
        step: 15
    })
});