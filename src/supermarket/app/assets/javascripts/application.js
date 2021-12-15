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
//= require jquery
//= require rails
//= require jquery.cookie
//= require placeholder
//= require fastclick
//= require modernizr
//= require foundation.min
//= require jquery.slugit
//= require checkbox
//= require cookbookShow
//= require cookbookFollowing
//= require joinOrganization
//= require organizationRoles
//= require announcementBanner
//= require flash
//= require select2.min
//= require collaborators
//= require groups
//= require group_members
//= require cookbookDeprecate
//= require cookbookInstallTabs
//= require organizations
//= require tools
//= require searchToggle
//= require advancedSearch

// Hack to resolve bug with Foundation. Resolved in master
// here: https://github.com/zurb/foundation/issues/4684 so
// this can go away when Foundation 5.2.3 is released.
Foundation.global.namespace = '';

$(function(){
  $(document).foundation();

  // Ensure client side validation isn't stronger
  // than serverside validation.
  jQuery.extend(window.Foundation.libs.abide.settings.patterns, {
    'password': /[a-zA-Z]+/,
  });
});
