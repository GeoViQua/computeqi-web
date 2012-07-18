$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }

    opts = $.extend({}, $.fn.spin.defaults, opts);
    data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
  });

  return this;
};

$.fn.spin.defaults = {};