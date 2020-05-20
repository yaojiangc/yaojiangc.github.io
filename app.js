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

    // $('#gallery-content .img-thumbnail:not(#main-image) a').hover(function() {
    //     event.currentTarget.click();
    // });

    $('#gallery-content').mouseenter(function() {
        $('.carousel').carousel('pause')
    });

    $('#gallery-content').mouseleave(function() {
        $('.carousel').carousel('cycle')
    });
});

/********************************************
* Projects Content Actions
********************************************/
window.onload = (event) => {
    $('.gallery-spinner').removeClass('d-flex');
    $('.gallery-spinner').addClass('d-none');
    $('#gallery-content').removeClass('d-none');
    $('#mypic').removeClass('d-none');
};

document.getElementById('mypic').addEventListener('load',function(){
    $('#about .gallery-spinner').removeClass('d-flex');
    $('#about .gallery-spinner').addClass('d-none');
    $('#mypic').removeClass('d-none');
});

document.getElementById('down-arrow').animate([
    { transform: 'translateY(0rem)'},
    { transform: 'translateY(-0.5rem)'},
    { transform: 'translateY(0rem)'}
], {
    duration: 1000,
    iterations: Infinity
});

document.getElementById('greeting').animate([
    { transform: 'scale(1)'},
    { transform: 'scale(1.1)'},
    { transform: 'scale(1)'}

], {
    duration: 4000,
    iterations: Infinity
});
