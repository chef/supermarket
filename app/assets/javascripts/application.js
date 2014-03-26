// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery-2.1.0.min
//= require jquery/rails
//= require placeholder
//= require fastclick
//= require modernizr
//= require foundation.min
//= require checkbox
//= require expandContributors
//= require flash
//= require truncatedDirectory

$(function(){
  $(document).foundation();

  // Ensure client side validation isn't stronger
  // than serverside validation.
  jQuery.extend(window.Foundation.libs.abide.settings.patterns, {
    'password': /[a-zA-Z]+/,
  });

  // Match side menu to page height
  $(function() {
    var timer;
    $(window).resize(function() {
      clearTimeout(timer);
      timer = setTimeout(function() {
        $('.inner-wrap').css("min-height", $(window).height() + "px" );
      }, 40);
    }).resize();
  });
});
