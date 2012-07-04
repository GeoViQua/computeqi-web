$(function() {
  $('.export .dropdown-toggle').on('click', function() {
    $('.export-option a').each(function() {
      var a = $(this);
      a.show();
      var select = a.siblings().hide().filter('select');
      select.attr('disabled', false).removeClass('disabled')
      if (select[0] !== undefined) {
        select[0].selectedIndex = 0;
      }
    });
  });
  
  $('.export-option input').on('click', function() {
    $(this).select();
    return false;
  });
  
  $('.export-option a').on('click', function() {
    var a = $(this);
    var parent = a.parent();
    if (parent.hasClass('enable-filter')) {
      a.hide();
      a.siblings('select').show();
    } else {
      parent.addClass('loading');
      var path = parent.parent().parent().data('resourcePath') + '.' + parent.data('format');
      $.get(path, function(response) {
        a.hide();
        parent.removeClass('loading');
        var input = a.next();
        input.val(response).focus().show().select();
      }, 'text');
    }
    return false;
  });
  
  $('.export-option select').on('change', function() {
    var select = $(this);
    var parent = select.parent();
    parent.addClass('loading');
    select.attr('disabled', true).addClass('disabled');
    var path = parent.parent().parent().data('resourcePath') + '.' + parent.data('format');
    $.get(path, { output_id: select.val() }, function(response) {
      select.hide();
      parent.removeClass('loading');
      var input = select.next();
      input.val(response).focus().show().select();
    }, 'text');
    return false;
  });
  
  $('.export-option input').on('click', function() {
    return false;
  });
});