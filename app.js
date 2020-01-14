/********************************************
* Index Content Actions
********************************************/
$(function(){
    $(document).scroll(function(){
        $('#mainNavBar').toggleClass(
            "scrolled", $(this).scrollTop() > $('.header').height()
            );
    });
});

$(document).ready(function(){
    $('.goToGallery').click(function() {
        $('html,body').animate({
                scrollTop: $('#gallery').offset().top+1},
            'slow');
    });

    $('.goToAbout').click(function() {
        $('html,body').animate({
                scrollTop: $('#about').offset().top},
            'slow');
    });

    $('.goToContact').click(function() {
        $('html,body').animate({
                scrollTop: $('#contact').offset().top},
            'slow');
    });

    $('.goToTop').click(function() {
        $('html,body').animate({
                scrollTop: 0},
            'slow');
    });
});

/********************************************
* Projects Content Actions
********************************************/
$(function(){
    $(document).scroll(function(){
        $('#projectsNavBar').toggleClass(
            "scrolled", $(this).scrollTop() > $('.header').height()
            );
    });
});


window.onload = (event) => {
    $('.gallery-spinner').removeClass("d-flex");
    $('.gallery-spinner').addClass("d-none");
    $('#gallery-content').removeClass('d-none');
    $('#mypic').removeClass('d-none');
};
