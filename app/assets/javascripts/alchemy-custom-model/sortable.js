
$(document).on("turbolinks:load",function () {

    $('.sortable_tree').nestedSortable({
        handle: 'div',
        items: 'li',
        cursor: 'pointer',
        scroll: true,
        toleranceElement: '> div',
        maxLevels: 1
    });

    $("#save_order").click(function(){

        var array_positions = $('#sort_tree').nestedSortable("toHierarchy");
        var url = $('#save_order').data("url-update");

        $.ajax({
            url: url,
            contentType: "application/json;charset=utf-8",
            data: JSON.stringify({ordered_data: array_positions}),
            method: "PUT"

        })


    });


});