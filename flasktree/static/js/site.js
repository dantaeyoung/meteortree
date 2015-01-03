$(function() {
  var tutorialData = null;
  var dependencyData = null;
  var courseData = null;

  d3.json("/tutorials?format=json", function(error, data) {
    data.sort(function(a,b) { return d3.ascending(parseInt(a.id), parseInt(b.id)); });
    tutorialData = data;
    drawSkilltree();
  });

  d3.json("/dependencies?format=json", function(error, data) {
    dependencyData = data;
    drawSkilltree();
  });

  $.ajax("/courses?format=json", {
    success: function (data, status, xhr) {
      courseData = data;
      drawSkilltree();
    }
  });

  function drawSkilltree() {
    if (tutorialData !== null && dependencyData !== null && courseData !== null) {
      setupTreeCanvas();
      lookupDefaultIconPath();
      drawLines(dependencyData);
      drawTutorials(tutorialData);
      drawCreate(tutorialData);
      drawTools(tutorialData, dependencyData);
      setupSteps();
      drawCourses(courseData);
    }
  }
});

function lookupDefaultIconPath() {
  window.tutorialDefaultIconPath = $("#javascript-helpers #tutorialDefaultIconPath").attr("src");
}

function setupTreeCanvas() {
  d3.select("svg.tree").append("g").attr("class", "tutorials");
  d3.select("svg.tree").append("g").attr("class", "paths");

  if ( $.cookie("treeScroll") !== null ) {
    $(".section-tree").scrollTop( $.cookie("treeScroll") );
  }

  $(window).on('beforeunload', function(){
    $.cookie("treeScroll", $(".section-tree").scrollTop() );
  });
}
