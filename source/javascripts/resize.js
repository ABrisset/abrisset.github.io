$(document).ready(function() {
  function setHeight() {
    windowHeight = $(window).innerHeight();
    $('.section--home').css('height', windowHeight);
  };
  setHeight();
  $(window).resize(function() {
    setHeight();
  });
});
