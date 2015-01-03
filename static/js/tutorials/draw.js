function redirectTutorialEdit(tutorial) {
  window.location.href = "/tutorials/" + tutorial.id + "/edit" + window.location.hash;
  window.location.reload();
}

function gridDatabaseToDisplay(p) {
  return {x: p.x * 100 + 20,
          y: p.y * 50 + 20};
}

function gridDisplayToDatabase(mouse) {
  return {x: Math.floor(mouse[0]/100),
          y: Math.floor((mouse[1] - 25)/50)};
}

function drawTutorials(tutorialData) {

  var alltutorials = d3.select("svg.tree g.tutorials").selectAll("g.tutorial").data(tutorialData);

  var newtutorials = alltutorials.enter().append("g")
      .attr("data-tutorial-id", function(d) { return d.id; })
      .attr("data-json", function(d) {return JSON.stringify(d);})
      .attr("class", function(d) {
        return "tutorial tutorial-" + d.id + " "  + d.publish;
      });

  newtutorials
    .attr("data-href", function(d) { return "/tutorials/" + d.id;}) 
    .append("image")
    .attr("xlink:href", function(d) { return d.iconPath || tutorialDefaultIconPath; })
    .attr("width",60).attr("height",60);

  newtutorials
    .append("rect")
    .attr("class","highlight")
    .attr("width",60).attr("height",60);

  newtutorials.append("text")
    .attr("class", "label")
    .attr("dx", 5)
    .attr("dy", 72)
    .text(function(d) { return d.title.toUpperCase(); });

  //drawToolboxes(tutorials);

  alltutorials.attr("transform", function(d) {
    var point = gridDatabaseToDisplay(d);
    return "translate(" + point.x + ", " + point.y + ")";
  });

  var allTutorialImages = d3.select("svg.tree").selectAll("g.tutorial image").data(tutorialData);
  
  $("g.tutorial").hover(function() {
     $(this).attr('class', function(index, classNames) {
       return classNames + ' hovering';
     });
  }, function() {
     $(this).attr('class', function(index, classNames) {
       return classNames.replace(' hovering', '');
     });
  });
    

  allTutorialImages.on("mousedown", function(d) {
    d.hasDragged = false;
    tutorialMover.start(d);
    $(".section-tree").addClass("dragging");
  }); 

  allTutorialImages.on("click", function(d) {

    if (window.isLoggedIn && d.hasDragged == true) return;

    if ($("body").hasClass("dependency-mode")) {
      d3.event.stopPropagation();
      tutorialDepender.finish(d);
      return;
    }
  
    $.cookie("treeScroll", $(".section-tree").scrollTop() );
    window.location.href = d3.select("g.tutorial-" + d.id).attr("data-href");
  });
  
  d3.select("svg.tree").on("mouseup", function() {
    if($(".section-tree").hasClass("dragging")) {
      tutorialMover.finish(d3.mouse(this));
      $(".section-tree").removeClass("dragging");
    }
  });

  return newtutorials;
}

function bezPath(d) {
  x1 = gridDatabaseToDisplay(d.source).x;
  y1 = gridDatabaseToDisplay(d.source).y + 30;
  x2 = gridDatabaseToDisplay(d.target).x + 60;
  y2 = gridDatabaseToDisplay(d.target).y + 30;
  return "M"
    + x1 + "," + y1
    + " C"
    + ((x2 + x1) / 2 - (Math.sqrt(y1 + y2) / 2)) + "," + y1
    + " "
    + ((x2 + x1) / 2 + (Math.sqrt(y1 + y2) / 2)) + "," + y2
    + " "
    + x2 + "," + y2;
}

function drawLines(dependencyData) {

  var allLines = d3.select("svg.tree g.paths").selectAll("path.dependency").data(dependencyData, function(d) {return d.id;})

  var oldLines = allLines.exit().remove();

  var newLines = allLines.enter().append("path");

  newLines
    .attr("class", function(d) {
      var classes  = "dependency source-of-" + d.source.id + " target-of-" + d.target.id;
      if(d.source.publish === "Draft" || d.target.publish === "Draft") {
        classes += " draft";
      }
      return classes;
    });

  allLines.attr("d", bezPath)
}
