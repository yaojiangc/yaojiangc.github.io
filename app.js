$(function(){
    $(document).scroll(function(){
        $('#mainNavBar').toggleClass(
            "scrolled", $(this).scrollTop() > $('#main-window').height()
            );
    });
});


$(document).ready(function(){
    $('#goToAbout').click(function() {
        $('html,body').animate({
                scrollTop: $('.about').offset().top},
            'slow');
    });

    $('#goToContact').click(function() {
        $('html,body').animate({
                scrollTop: $('.contact').offset().top},
            'slow');
    });

    $('.goToTop').click(function() {
        $('html,body').animate({
                scrollTop: 0},
            'slow');
    });
});