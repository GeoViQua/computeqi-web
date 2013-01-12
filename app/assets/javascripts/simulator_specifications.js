$(function() {
  function toggleInputs(parent, selected) {
    var opts = { duration: 'fast' };
    var lselected = selected.toLowerCase();
    var classes = [ '.fixed', '.variable', '.samples' ];
    var selclass = classes.splice(classes.indexOf('.' + lselected), 1)[0];

    // update hidden field
    parent.find('input[name$="[value_type]"]').val(lselected);

    // update visibility
    parent.find(classes.join()).not(':hidden').slideUp('fast', function() {
      parent.find(selclass).slideDown('fast');
    });

    // update toggles
    parent.find('.btn[data-value="' + lselected + '"]').button('toggle');
  }

  $('.data-toggle').on('click', function() {
    $parent = $(this).parent();
    $view = $parent.siblings('.data-view');
    if ($view.is(':hidden')) {
      var values = $parent.siblings('input').val();
      $view.html(values.split(',').join(', ')).slideDown('fast');
    } else {
      $view.slideUp('fast', function() {
        $view.html('');
      });
    }
    return false;
  });

  $('.btn-group[data-toggle="buttons-radio"] .btn').on('click', function() {
    var btn = $(this);
    btn.button('toggle');
    var fieldset = btn.parent().parent().parent().parent();
    toggleInputs(fieldset, btn.text());
    return false;
  });

  uploader.bind('FileUploaded', function(up, file, response) {
    // get data from csv
    var rows = JSON.parse(response.response);
    var first = rows.splice(0, 1)[0];

    // get input names
    var names = [];
    $('.span6').each(function(index, item) {
      names.push($(item).data('name'));
    });
    
    // create indices for templating
    var headings = [];
    for (var i = 0; i < first.length; i++) {
      headings.push({ index: i, name: first[i] });
    }

    // render table
    var table = Mustache.to_html($('#table-template').val(), { headings: headings, names: names, rows: rows });
    $('#import-result').html(table);
    var names = Mustache.to_html($('#names-template').val(), { names: names });
    $('#import-result select').html(names);

    // auto select
    for (var n = 1; n <= headings.length; n++) {
      var heading = $('#import-result tr:nth-child(1) th:nth-child(' + n + ')').html();
      var select = $('#import-result tr:nth-child(2) th:nth-child(' + n + ') select');
      select.val(heading);
    }

    // show dialog
    $('#import-dialog').modal({ show: true, keyboard: true, backdrop: 'static' });
  });

  uploader.bind('UploadComplete', function(up, files) {

  });

  $('#import-cancel').click(function() {
    $('#import-dialog').modal('hide');
  });

  $('#import-submit').click(function() {
    // get each column which has an input selected
    $('#import-result select option[value!=""]:selected').each(function(i, option) {
      // get n for nth-child and name
      var n = $(option).parent().parent().index() + 1;
      var name = $(option).val();

      // get values, add to array
      var values = [];
      $('#import-result td:nth-child(' + n + ')').each(function(i, td) {
        values.push($(td).text());
      });

      // set input to csv string and toggle
      var $span = $('.span6[data-name="' + name + '"]');
      $span.find('input[name$="[sample_values]"]').val(values.join());
      $span.find('span.import-count').html(values.length);
      toggleInputs($span, 'samples');
    });

    // all done
    $('#import-dialog').modal('hide');
  });
});