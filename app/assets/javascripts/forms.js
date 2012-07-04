$(function() {
  $('.form-togglable .btn').on('click', function() {
    var btn = $(this);
    btn.button('toggle');
    btn.siblings('input[type="hidden"]').val(btn.hasClass('active'));
    btn.siblings('input[type="text"]').prop('disabled', !btn.hasClass('active'));
    return false;
  })

  $('.form-toggle .btn-group').button().find('.btn').on('click', function() {
    var btn = $(this)
    btn.button('toggle');
    btn.parent().siblings('input').val(btn.data('value'));
    return false;
  });

  $('.form-array .add').live('click', function() {
    var a = $(this);
    var parent = a.parent();
    
    // add input
    var name = parent.parent().data('arrayName');
    var element = $('<div class="form-array-value"><input name="' + name + '[]" type="text"> <a class="add" href="#"><i class="icon-plus-sign"></i></a> <a class="remove" href="#"><i class="icon-minus-sign"></i></a></div>').hide();
    
    // hide help if necessary and add
    parent.after(element);
    if (parent.hasClass('nothing-block')) {
      parent.fadeOut('fast', function() {
        element.slideDown('fast');
      });
    } else {
      element.slideDown('fast');
    }
    
    return false;
  });
  
  $('.form-array .remove').live('click', function() {
    var a = $(this);
    var parent = a.parent();
    
    // remove
    parent.slideUp(function() {
      var siblings = parent.siblings();
      if (siblings.size() == 1) {
        siblings.filter('.nothing-block').fadeIn('fast');
      }
      $(this).remove();
    });
    
    return false;
  });

  $('.form-slider input[type="range"]').on('change', function() {
    var range = $(this);
    var input = range.siblings('input[type="text"]');

    // update
    input.val(range.val());
  });

  $('.form-slider input[type="text"]').on('change', function() {
    var input = $(this);
    var range = input.siblings('input[type="range"]');

    // update
    var val = parseInt(input.val());
    var min = parseInt(range.attr('min'))
    var max = parseInt(range.attr('max'));
    if (val > max) {
      val = max;
    } else if (val < min) {
      val = min;
    }
    input.val(val);
    range.val(val);
  });
});