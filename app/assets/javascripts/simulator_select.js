$(function() {
  $('#service-select select').on('change', function() {
    refreshProcessList();
  });

  $('#process-select select').on('change', function() {
    refreshIOList();
  });

  refreshProcessList();

  $('.busy').spin();

  function appendHiddenInputs(parent, identifier, params) {
    for (var i = 0; i < params.length; i++) {
      var param = params[i];
      $('<input />', {
        type: 'hidden',
        name:  $('.simulator-select').data('parent') + '[simulator_specification_attributes][' + identifier + '][][' + param.name + ']',
        value: param.value
      }).appendTo(parent);
    }
  }

  function refreshProcessList() {
    $('#process-select').slideUp('fast');
    $('#service-select .busy').fadeIn('fast');
    $('.simulator-select').parents('form').find('input[type="submit"]').prop('disabled', true);

    var s = $('#service-select select');
    var p = $('#process-select select');
    p.children().remove();

    var request = {
      type: 'GetProcessIdentifiersRequest',
      serviceURL: s.val()
    };

    $e.apiRequest(request, function(data) {
      var ids = data.processIdentifiers;
      for (var i = 0; i < ids.length; i++) {
        p.append('<option value="' + ids[i] + '">' + ids[i] + '</option>');
      }
      $('#service-select .busy').fadeOut('fast');
      $('#process-select').slideDown('fast');
      refreshIOList();
    }, function(error) {
      console.log(error);
    });
  }

  function refreshIOList() {
    $('#process-select .help-block').slideUp('fast');
    $('#process-select .busy').fadeIn('fast');
    $('.simulator-select').parents('form').find('input[type="submit"]').prop('disabled', true);

    var s = $('#service-select select');
    var p = $('#process-select select');
    var i = $('#inputs');
    var o = $('#outputs');
    i.children().remove();
    o.children().remove();

    var request = {
      type: 'GetProcessDescriptionRequest',
      serviceURL: s.val(),
      processIdentifier: p.val()
    };

    $e.apiRequest(request, function(data) {
      var pd = data.processDescription;
      $('input[name="' + $('.simulator-select').data('parent') + '[simulator_specification_attributes][process_description]"]').val(pd.detail);

      var id = pd.inputs;
      var od = pd.outputs;
      var itext = '';
      var otext = '';
      for (var n = 0; n < id.length; n++) {
        var arr = [
          { name: 'name', value: id[n].identifier },
          { name: 'minimum_value', value: '0' },
          { name: 'maximum_value', value: '1' }
        ];
        if (id[n].description) {
          arr.push({ name: 'description', value: id[n].description.detail });
        }
        appendHiddenInputs(i, 'inputs_attributes', arr);
        // hidden for now
        itext += id[n].identifier + ', ';
      }
      //i.append('<span class="help-block">' + itext.substring(0, itext.length - 2) + '</span>');

      for (var n = 0; n < od.length; n++) {
        var arr = [{ name: 'name', value: od[n].identifier }];
        if (od[n].description) {
          arr.push({ name: 'description', value: od[n].description.detail });
        }
        appendHiddenInputs(o, 'outputs_attributes', arr);
        // hidden for now
        otext += od[n].identifier + ', ';
      }
      //o.append('<span class="help-block">' + otext.substring(0, otext.length - 2) + '</span>');

      $('#process-select .help-block').html(pd.detail);
      if (pd.detail) {
        $('#process-select .help-block').slideDown('fast');
      }
      $('#process-select .busy').fadeOut('fast');
      $('.simulator-select').parents('form').find('input[type="submit"]').prop('disabled', false);
    });
  }
});
