$.fn.alchemyCustomModelSelect = function(options) {

    return this.select2({
        placeholder: options.placeholder,
        allowClear: true,
        initSelection: function(element, callback) {
            console.log("pippo")
            var id = $(element).val();
            console.log(id)
            if (id !== "") {
                var q = {}
                if (options.query_params){
                    q = options.query_params()
                }
                $.ajax(options.url, {
                    dataType: "json",
                    data: {
                        id: id,
                        q: q,
                        per_page: 3000
                    }
                }).done(function(data) {
                    var el = null
                    $.each(data.results, function(index,element){
                        if (element.text == id){

                            el = element
                        }
                    })
                    callback(el);
                });
            }
        },
        ajax: {
            url: options.url,
            datatype: 'json',
            quietMillis: 300,
            data: function (term, page) {
                var extend_query_params = {}
                if (options.query_params) {

                    extend_query_params =  options.query_params(term,page)

                }
                return {
                    q: $.extend({
                        name: term
                    }, extend_query_params),
                    page: page
                }
            },
            results: function (data) {
                var meta = data.meta
                return {
                    results: data.results,
                    more: meta.page * meta.per_page < meta.total_count
                }
            }
         },

    })
}