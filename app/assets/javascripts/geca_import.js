$(function() {

  geca_uploader.bind('FileUploaded', function(up, file, response) {

    var response = JSON.parse(response.response);

    $('.alert').remove();

    if (response.error) {
      $('#new_validation').prepend('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a>' + response.error.message + '</div>');
      file.status = plupload.FAILED;
    }
    else {
      // get data from csv
      var rows = response;
    }
  });

  geca_uploader.bind('UploadComplete', function(up, files) {

  });

});