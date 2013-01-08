$(function() {
  function toggleInputs(parent, selected) {
    var opts = { duration: 'fast' };
    var classes = [ '.fixed', '.variable', '.samples' ];
    var selclass = classes.splice(classes.indexOf('.' + selected.toLowerCase()), 1)[0];
    parent.find(classes.join()).not(':hidden').slideUp('fast', function() {
      parent.find(selclass).slideDown('fast');
    });
  }

  $('.btn-group[data-toggle="buttons-radio"] .btn').click(function() {
    var btn = $(this);
    btn.button('toggle');
    var fieldset = btn.parent().parent().parent().parent();
    toggleInputs(fieldset, btn.text());
    return false;
  });

  $('form').submit(function(e) {
    $('.control-group:hidden input').val('');
  });
});