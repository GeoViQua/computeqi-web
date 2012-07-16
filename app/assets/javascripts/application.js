// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery_ujs
//= require twitter/bootstrap/button
//= require twitter/bootstrap/dropdown
//= require twitter/bootstrap/tab
//= require twitter/bootstrap/tooltip
//= require spin.min
//= require emulatorization
//= require_self

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};

$(function() {
  
  $('.alert .close').on('click', function() {
    var alert = $(this).parent();
    alert.slideUp('fast', function() {
      alert.remove();
    });
  });

  $('.dropdown-toggle').dropdown();

  $('.boxed.clickable').on('click', function() {
    link = $(this).find('a').attr('href');
    if (typeof(link) !== 'undefined') {
      window.location = link;
    }
    return false;
  });

  $('[rel="tooltip"]').tooltip();
  
});