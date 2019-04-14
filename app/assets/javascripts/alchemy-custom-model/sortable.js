
$(document).on("turbolinks:load",function () {

    $('.sortaable_tree').nestedSortable({
        handle: 'div',
        items: 'li',
        cursor: 'pointer',
        scroll: true,
        toleranceElement: '> div',
        maxLevels: 1
    });

    $("#save_order").click(function(){

        var array_positions = $('#sort_tree').nestedSortable("toHierarchy");
        var url = $('#sort_tree').data("url-update");
        $.post({
            url: url,
            data: JSON.stringify({data: array_positions}),
            contentType: "application/json;charset=utf-8"
        });

    });


});