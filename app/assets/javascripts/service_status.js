$(function() {
  $.get($e.service_status_path, function(response) {
    var okIcon = '<i class="icon-ok-sign"></i>';
    var errorIcon = '<i class="icon-exclamation-sign"></i>';
    if (response.type == 'StatusResponse') {
      $('.api .status').html(okIcon);
      if (response.matlabOK) {
        $('.matlab .status').html(okIcon);
      } else {
        $('.matlab .status').html(errorIcon);
      }
      if (response.rserveOK) {
        $('.rserve .status').html(okIcon);
      } else {
        $('.rserve .status').html(errorIcon);
      }
    } else {
      $('.status').html(errorIcon);
    }
    $('.api .status i').attr('rel', 'tooltip').attr('title', response.message);
    $('.matlab .status i').attr('rel', 'tooltip').attr('title', response.matlabMessage);
    $('.rserve .status i').attr('rel', 'tooltip').attr('title', response.rserveMessage);
    $('[rel="tooltip"]').tooltip();
  }, 'json');
});