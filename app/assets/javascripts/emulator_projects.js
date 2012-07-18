$(function() {
  $('#emulator_project_simulator_specification_attributes_service_url').on('change', function() {
    refreshProcessList();
  });

  $('#emulator_project_simulator_specification_attributes_process_name').on('change', function() {
    refreshIOList();
  });

  refreshProcessList();

  $('.busy').spin();
});

function appendHiddenInputs(parent, identifier, params) {
  for (var i = 0; i < params.length; i++) {
    var param = params[i];
    $('<input />', {
      type: 'hidden',
      name: 'emulator_project[simulator_specification_attributes][' + identifier + '][][' + param.name + ']',
      value: param.value
    }).appendTo(parent);
  }
}

function refreshProcessList() {
  $('#process-select').slideUp('fast');
  $('#service-select .busy').fadeIn('fast');
  $('input[type="submit"]').prop('disabled', true);

  var s = $('#emulator_project_simulator_specification_attributes_service_url');
  var p = $('#emulator_project_simulator_specification_attributes_process_name');
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
  $('input[type="submit"]').prop('disabled', true);

  var s = $('#emulator_project_simulator_specification_attributes_service_url');
  var p = $('#emulator_project_simulator_specification_attributes_process_name');
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
    $('input[name="emulator_project[simulator_specification_attributes][process_description]"]').val(pd.detail);

    var id = pd.inputDescriptions;
    var od = pd.outputDescriptions;
    var itext = '';
    var otext = '';
    for (var n = 0; n < id.length; n++) {
      appendHiddenInputs(i, 'inputs_attributes', [
        { name: 'name', value: id[n].identifier },
        { name: 'description', value: id[n].detail },
        { name: 'minimum_value', value: '0' },
        { name: 'maximum_value', value: '1' }
      ]);
      // hidden for now
      itext += id[n].identifier + ', ';
    }
    //i.append('<span class="help-block">' + itext.substring(0, itext.length - 2) + '</span>');

    for (var n = 0; n < od.length; n++) {
      appendHiddenInputs(o, 'outputs_attributes', [
        { name: 'name', value: od[n].identifier },
        { name: 'description', value: od[n].detail }
      ]);
      // hidden for now
      otext += od[n].identifier + ', ';
    }
    //o.append('<span class="help-block">' + otext.substring(0, otext.length - 2) + '</span>');

    $('#process-select .help-block').html(pd.detail);
    if (pd.detail) {
      $('#process-select .help-block').slideDown('fast');
    }
    $('#process-select .busy').fadeOut('fast');
    $('input[type="submit"]').prop('disabled', false);
  });
}
