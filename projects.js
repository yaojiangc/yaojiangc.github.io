/********************************************
* Index Content Actions
********************************************/
$(function(){
    $(document).scroll(function(){
        $('#projectsNavBar').toggleClass(
            "scrolled", $(this).scrollTop() > $('.header').height()
            );
    });
});

/********************************************
* Projects Content Actions
********************************************/
function loadFile(filePath) {
    var result = null;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.open("GET", filePath, false);
    xmlhttp.send();
    if (xmlhttp.status==200) {
      result = xmlhttp.responseText;
    }
    return result;
}

$(document).ready(function(){
    $('.goToTop').click(function() {
        $('html,body').animate({
                scrollTop: 0},
            'slow');
    });

    $('.goToProject1').click(function() {
        $('html,body').animate({
                scrollTop: $('#project1').offset().top},
            'slow');
    });

    $('.goToProject2').click(function() {
        $('html,body').animate({
                scrollTop: $('#project2').offset().top},
            'slow');
    });

    $('.goToProject3').click(function() {
        $('html,body').animate({
                scrollTop: $('#project3').offset().top},
            'slow');
    });

    $('.goToProject4').click(function() {
        $('html,body').animate({
                scrollTop: $('#project4').offset().top},
            'slow');
    });

    $('.goToProject5').click(function() {
        $('html,body').animate({
                scrollTop: $('#project5').offset().top},
            'slow');
    });

    // Set ACE Editor
    var editorList = [
        {
            id: "mips_editor",
            type: "vhdl",
            filename: "/src_examples/mipsprocessor_pipe.vhd" 
        },
        {
            id: "camera_editor",
            type: "matlab",
            filename: "/src_examples/bayer2ycbcr.m" 
        },
        {
            id: "ppm_cap_editor",
            type: "vhdl",
            filename: "/src_examples/capture_ppm.vhd" 
        },
        {
            id: "ppm_gen_editor",
            type: "vhdl",
            filename: "/src_examples/generate_ppm.vhd" 
        },
        {
            id: "mars_rover_editor",
            type: "c_cpp",
            filename: "/src_examples/main.c" 
        }
    ];
    for(var i=0; i<editorList.length; i++)
    {
        var editor = ace.edit(editorList[i].id);    
        editor.setReadOnly(true);
        editor.setTheme("ace/theme/monokai")
        var JavaScriptMode = ace.require("ace/mode/" + editorList[i].type).Mode;
        editor.session.setMode(new JavaScriptMode());
        editor.session.setValue(loadFile(editorList[i].filename));
    }

    document.getElementById('greeting').animate([
        { transform: 'scale(1)'},
        { transform: 'scale(1.1)'},
        { transform: 'scale(1)'}
    
    ], {
        duration: 4000,
        iterations: Infinity
    });

});

