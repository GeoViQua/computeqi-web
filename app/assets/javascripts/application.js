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
//= require spin/spin
//= require spin/jquery.spin
//= require mustache/mustache
//= require forms
//= require emulatorization
//= require_self

$.fn.spin.defaults = {
  lines: 11, // The number of lines to draw
  length: 3, // The length of each line
  width: 2, // The line thickness
  radius: 4, // The radius of the inner circle
  rotate: 0, // The rotation offset
  color: '#000', // #rgb or #rrggbb
  speed: 1.2, // Rounds per second
  trail: 60, // Afterglow percentage
  shadow: false, // Whether to render a shadow
  hwaccel: false, // Whether to use hardware acceleration
  className: 'spinner', // The CSS class to assign to the spinner
  zIndex: 2e9, // The z-index (defaults to 2000000000)
  top: 'auto', // Top position relative to parent in px
  left: 'auto' // Left position relative to parent in px
};

$(function() {
  
  $('.alert .close').on('click', function() {
    var alert = $(this).parent();
    alert.slideUp('fast', function() {
      alert.remove();
    });
  });

  $('.dropdown-toggle').dropdown();

  // $('.boxed.clickable').on('click', function() {
  //   link = $(this).find('a').attr('href');
  //   if (typeof(link) !== 'undefined') {
  //     window.location = link;
  //   }
  //   return false;
  // });

  $('[rel="tooltip"]').tooltip();
  
});