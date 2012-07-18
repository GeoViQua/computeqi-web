$(function() {
  $('.btn-group[data-toggle="buttons-radio"] .btn').click(function() {
    var btn = $(this);
    btn.button('toggle');
    var div = btn.parent().parent().parent();
    if (btn.text() == 'Fixed') {
      div.siblings(':nth-child(4), :nth-child(5)').slideUp('fast', function() {
        div.siblings(':nth-child(3)').slideDown('fast');
      });
    } else {
      div.siblings(':nth-child(3)').slideUp('fast', function() {
        div.siblings(':nth-child(4), :nth-child(5)').slideDown('fast');
      });
    }
    return false;
  });

  $('form').submit(function(e) {
    $('.control-group:hidden input').val('');
  });
});