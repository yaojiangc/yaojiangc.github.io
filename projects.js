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
            filename: "mipsprocessor_pipe.vhd" 
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

});

