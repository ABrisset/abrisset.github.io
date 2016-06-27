$(document).ready(function() {
  $('.scroll').click( function() { // Onclick
    var page = $(this).attr('href'); // Target page
    var speed = 250; // Animation duration (ms)
    $('html, body').animate( { scrollTop: $(page).offset().top }, speed ); // Go
    return false;
  });
});
