// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('DOMContentLoaded', function() {
  // Initialize Select2
  if (typeof jQuery !== 'undefined' && typeof jQuery.fn.select2 !== 'undefined') {
    jQuery('.select2').select2();
  }

  // Initialize AdminLTE
  if (typeof jQuery !== 'undefined' && typeof jQuery.fn.layout !== 'undefined') {
    jQuery('body').layout();
  }
});
