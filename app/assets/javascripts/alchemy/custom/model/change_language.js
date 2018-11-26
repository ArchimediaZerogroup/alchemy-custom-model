
$(document).on("page:change turbolinks:load",function () {

    $('select#change_language').on('change',function (e){
        var url = window.location.pathname;
        var delimiter = url.match(/\?/) ? '&' : '?';
        Turbolinks.visit(url+delimiter+"language_id="+$(this).val());
    });

});

