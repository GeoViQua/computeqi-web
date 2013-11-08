$(function() {

  var inputs = {},
      $import_save = $('#import-save'),
      $import_submit = $('#import-submit'),
      $data_dropdown = $('select[name="type"]');

  var fileUploaded = function(up, file, response) {
    
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

      // reset saved inputs
      inputs = {};

      // disable save & import buttons
      $import_save.prop('disabled', true);
      $import_submit.prop('disabled', true);

      // show dialog
      $('#import-dialog').modal({ show: true, keyboard: true, backdrop: 'static' });
    }
  }

  var uploadComplete = function(up, files) {

  }

  uploader.bind('FileUploaded', fileUploaded);
  uploader.bind('UploadComplete', uploadComplete);
  geca_uploader.bind('FileUploaded', fileUploaded);
  geca_uploader.bind('UploadComplete', uploadComplete);

  this.addData = function(type, data) {
    var id = data.id;
    var value = data.value;
    var base = 'validation[' + type + '][' + id + ']';

    var $input = $('<input/>').attr('type', 'hidden');
    $input.attr('name', base);
    $input.val(JSON.stringify(value));

    inputs[type]["values"].push($input);
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

  this.updateSelectedVariable = function(css_class) {
    var css_class = typeof css_class !== 'undefined' ? css_class : 'selected-var';
    var type = $('#var-toggle .btn.active').data('value');

    // remove old selection
    var table = $('#import-result table');
    if (css_class == 'saved-var') {
      table.find('td').removeClass('selected-var saved-var');
    }
    else {
      table.find('.'+css_class).removeClass(css_class);
    }

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
          table.find('tr > td:nth-child(n+'+from+'):nth-child(-n+'+to+')').addClass(css_class);
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
        table.find('tr > td:nth-child('+mean+')').addClass(css_class);
      }
      if (!isNaN(variance)) {
        table.find('tr > td:nth-child('+variance+')').addClass(css_class);
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
    $type = $('#' + type + '-params');
    if (!$type.is(":visible")) {
      $('.params[data-type="variable"]').not($type).slideUp('fast');
      $type.slideDown('fast');
    }
    that.updateSelectedVariable();
  };

  var that = this;

  $data_dropdown.on('change', function() {
    var type = $(this).val();
    var $btn = $('#var-toggle .btn:first-child');
    var $btns = $('#var-toggle .btn:nth-child(n+2):nth-child(-n+3)');
    /*if ($(this).val() === 'observed') {
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
    }*/
    $btns.prop('disabled', true).removeClass('active').addClass('disabled');
    $btn.prop('disabled', false).removeClass('disabled').addClass('active');
    that.updateSelectedVariableType('scalar');

    if (inputs.hasOwnProperty(type)) {
      if (inputs[type]['vartype'] == 'scalar') {
        $('#var-'+inputs[type]['vartype']).val(inputs[type]["varselected"][0]).trigger('change');
      }
    }
  });

  $('select[id^="id-"]').on('change', function() {
    that.updateSelectedId();
  });

  $('select[id^="var-"]').on('change', function() {
    var type = $data_dropdown.val(),
        val = $(this).val();

    $import_save.prop('disabled', isNaN(val));

    var css;

    if (inputs.hasOwnProperty(type)) {
      if ($.inArray(parseInt(val), inputs[type]["varselected"]) != -1) {
        css = 'saved-var';
      }
    }
    else {
      $('#import-result table').find('td').removeClass('saved-var');
    }

    that.updateSelectedVariable(css);
  });

  $('#id-toggle .btn').on('click', function() {
    var value = $(this).data('value');
    that.updateSelectedIdType(value);
  });

  $('#var-toggle .btn').on('click', function() {
    var value = $(this).data('value');
    that.updateSelectedVariableType(value);
  });

  $('#import-save').on('click', function(event) {
    event.preventDefault();

    var type = $data_dropdown.val();
    var idtype = $('#id-toggle .btn.active').data('value');
    var vartype = $('#var-toggle .btn.active').data('value');

    var count = parseInt($('#' + type + '-count').html());
    inputs[type] = { idtype: idtype, vartype: vartype, values: [] };

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
        var selected = $('#var-scalar').val();
        var child = parseInt(selected) + 1;
        value = parseFloat($(this).find('td:nth-child(' + child + ')').html());
        inputs[type]["varselected"] = [parseInt(selected)];
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

    // set the selection to saved
    that.updateSelectedVariable('saved-var');

    // enable import button
    $import_submit.prop('disabled', false);
  });

  $('#import-cancel').click(function() {
    inputs = {};
    $('#import-dialog').modal('hide');
  });

  $import_submit.click(function(event) {
    event.preventDefault();

    for (var type in inputs) {
      if (inputs.hasOwnProperty(type)) {

        var $container = $('#' + type + '-container');

        for (var index in inputs[type]["values"]) {
          $container.append(inputs[type]["values"][index]);
        }

        $count = $('#' + type + '-count');
        $count.html(parseInt($count.html()) + inputs[type]["values"].length);
      }
    }

    $('#import-dialog').modal('hide');
  });

});