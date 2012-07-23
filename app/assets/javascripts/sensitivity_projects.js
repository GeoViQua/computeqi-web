$(function() {

  $('.btn-group[data-toggle="buttons-radio"] .btn').click(function() {
    var btn = $(this);
    btn.button('toggle');
    var fieldsets = btn.parent().parent().parent().siblings('fieldset');
    if (btn.text() == 'Emulator') {
      fieldsets.eq(0).slideUp('fast', function() {
        fieldsets.eq(1).slideDown('fast');
      });
    } else {
      fieldsets.eq(1).slideUp('fast', function() {
        fieldsets.eq(0).slideDown('fast');
      });
    }
    return false;
  });

});