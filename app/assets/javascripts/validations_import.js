$(function() {

  uploader.bind('FileUploaded', function(up, file, response) {
    
    var response = JSON.parse(response.response);

    $('.alert').remove();

    if (response.error) {
      $('#new_validation').prepend('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a>' + response.error.message + '</div>');
      file.status = plupload.FAILED;
    }
    else {
      // get data from csv
      var rows = response;
      var first = rows.splice(0, 1)[0];

      // create indices for templating
      var headings = [];
      for (i = 0; i < first.length; i++) {
        headings.push({ index: i, name: first[i] });
      }

      // render selections
      var options = Mustache.to_html($('#options-template').val(), headings);
      $('select[id^="id-"], select[id^="var-"]').html(options);

      // render table
      var table = Mustache.to_html($('#table-template').val(), { headings: headings, rows: rows });
      $('#import-result').html(table);

      // show dialog
      $('#import-dialog').modal({ show: true, keyboard: true, backdrop: 'static' });
    }
  });

  uploader.bind('UploadComplete', function(up, files) {

  });

  this.addData = function(type, data) {
    var $container = $('#' + type + '-container');

    var id = data.id;
    var value = data.value;
    var base = 'validation[' + type + '][' + id + ']';

    var $input = $('<input/>').attr('type', 'hidden');
    $input.attr('name', base);
    $input.val(JSON.stringify(value));

    $container.append($input);
  };

  this.updateSelectedId = function() {
    var type = $('#id-toggle .btn.active').data('value');

    // get range for selection
    var from;
    var to;
    if (type === 'single') {
      from = parseInt($('#id-single').val()) + 1;
      to = from;
    } else {
      from = parseInt($('#id-first').val()) + 1;
      to = parseInt($('#id-last').val()) + 1;
    }

    // remove old selection from table
    var table = $('#import-result table');
    table.find('.selected-id').removeClass('selected-id');

    // check if valid
    var text = '';
    if (!isNaN(from) && !isNaN(to)) {
      // check if to after from
      if (from > to) {
        text = 'Last column cannot precede first.';
      } else {
        // update table
        table.find('tr > td:nth-child(n+'+from+'):nth-child(-n+'+to+')').addClass('selected-id');

        if (type === 'multiple') {
          $(table).find('tr:nth-child(2) .selected-id').each(function() {
            text += $(this).html();
          });
          text = 'Sample <code>' + text + '</code>';
        }
      }
    } else {
      text = 'Need more information.';
    }

    $('#id-help').html(text);
  };

  this.updateSelectedVariable = function() {
    var type = $('#var-toggle .btn.active').data('value');

    // remove old selection
    var table = $('#import-result table');
    table.find('.selected-var').removeClass('selected-var');

    // check type and update
    var text = '';
    if (type === 'scalar' || type === 'ensemble') {
      // get range
      var from;
      var to;
      if (type === 'scalar') {
        from = parseInt($('#var-scalar').val()) + 1;
        to = from;
      } else {
        from = parseInt($('#var-ens-first').val()) + 1;
        to = parseInt($('#var-ens-last').val()) + 1;
      }

      if (!isNaN(from) && !isNaN(to)) {
        if (from > to) {
          text = 'Last column cannot precede first.';
        } else {
          // update
          table.find('tr > td:nth-child(n+'+from+'):nth-child(-n+'+to+')').addClass('selected-var');
        }
      } else {
        text = 'Need more information.';
      }
    } else {
      // mean and variance
      var mean = parseInt($('#var-mean').val()) + 1;
      var variance = parseInt($('#var-variance').val()) + 1;

      // update
      if (!isNaN(mean)) {
        table.find('tr > td:nth-child('+mean+')').addClass('selected-var');
      }
      if (!isNaN(variance)) {
        table.find('tr > td:nth-child('+variance+')').addClass('selected-var');
      }
    }

    $('#var-help').html(text);
  };

  this.updateSelectedIdType = function(type) {
    $('#auto-params').slideUp('fast');
    $('#single-params').slideUp('fast');
    $('#multiple-params').slideUp('fast');
    $('#' + type + '-params').slideDown('fast');
    that.updateSelectedId();
  };

  this.updateSelectedVariableType = function(type) {
    $('#ensemble-params').slideUp('fast');
    $('#distribution-params').slideUp('fast');
    $('#scalar-params').slideUp('fast');
    $('#' + type + '-params').slideDown('fast');
    that.updateSelectedVariable();
  };

  var that = this;

  $('select[name="type"]').on('change', function() {
    var $btn = $('#var-toggle .btn:first-child');
    var $btns = $('#var-toggle .btn:nth-child(n+2):nth-child(-n+3)');
    if ($(this).val() === 'observed') {
      $btns.prop('disabled', true).removeClass('active').addClass('disabled');
      $btn.prop('disabled', false).removeClass('disabled').addClass('active');
      that.updateSelectedVariableType('scalar');
      that.updateSelectedVariable();
    } else {
      if ($('#var-toggle .btn.active').data('value') === 'scalar') {
        $($btns.get(0)).addClass('active');
        that.updateSelectedVariableType('distribution');
        that.updateSelectedVariable();
      }
      $btn.prop('disabled', true).removeClass('active').addClass('disabled');
      $btns.prop('disabled', false).removeClass('disabled');
    }
  });

  $('select[id^="id-"]').on('change', function() {
    that.updateSelectedId();
  });

  $('select[id^="var-"]').on('change', function() {
    that.updateSelectedVariable();
  });

  $('#id-toggle .btn').on('click', function() {
    var value = $(this).data('value');
    that.updateSelectedIdType(value);
  });

  $('#var-toggle .btn').on('click', function() {
    var value = $(this).data('value');
    that.updateSelectedVariableType(value);
  });

  $('#import-cancel').click(function() {
    $('#import-dialog').modal('hide');
  });

  $('#import-submit').click(function() {
    var type = $('select[name="type"]').val();
    var idtype = $('#id-toggle .btn.active').data('value');
    var vartype = $('#var-toggle .btn.active').data('value');

    var count = 0;

    // need checks before this
    // duplicate ids?

    $('#import-result table tr:not(:first-child)').each(function() {
      // get id
      var id;
      if (idtype === 'auto') {
        id = count.toString();
      } else {
        id = '';
        $(this).find('td.selected-id').each(function() {
          id += $(this).html();
        });
      }

      // get value
      var value;
      if (vartype === 'scalar') {
        // scalar
        var child = parseInt($('#var-scalar').val()) + 1;
        value = parseFloat($(this).find('td:nth-child(' + child + ')').html());
      } else if (vartype === 'distribution') {
        // distribution
        var meanChild = parseInt($('#var-mean').val()) + 1;
        var varianceChild = parseInt($('#var-variance').val()) + 1;
        var mean = parseFloat($(this).find('td:nth-child(' + meanChild + ')').html());
        var variance = parseFloat($(this).find('td:nth-child(' + varianceChild + ')').html());
        value = { mean: mean, variance: variance };
      } else {
        // ensembles
        value = [];
        var firstChild = parseInt($('#var-ens-first').val()) + 1;
        var lastChild = parseInt($('#var-ens-last').val()) + 1;
        $(this).find('td:nth-child(n+' + firstChild + '):nth-child(-n+' + lastChild + ')').each(function() {
          value.push(parseFloat($(this).html()));
        });
      }

      // add
      that.addData(type, { id: id, value: value });
      count++;
    });

    // all done
    $count = $('#' + type + '-count')
    $count.html(parseInt($count.html()) + count);
    $('#import-dialog').modal('hide');
  });

});