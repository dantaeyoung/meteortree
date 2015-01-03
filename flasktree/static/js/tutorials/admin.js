var bullseyes = null;
var toolboxes = null;

function drawTools(tutorialData, dependencyData) {
  if (window.isLoggedIn) {
     $("body").addClass("logged-in");
  }

  if (window.isLoggedIn && ("#tools" === window.location.hash || "" === window.location.hash)) {
    $(".modeTray .toolsButton").addClass("active");
    var grid = d3.select("svg.tree");
    drawToolboxes(tutorialData); //grid.selectAll("g.tutorial"));
    addEditHandlers(grid);
    tutorialMover.init(grid, tutorialData, dependencyData);
    tutorialDepender.init(dependencyData);
  }
}

function drawTool(toolboxes, tool) {
  return toolboxes.append("text")
    .attr("dx", tool.dx)
    .attr("dy", tool.dy || 0)
    .attr("style","font-size: 25px; font-weight: regular")
    .attr("data-json", function(d) {return JSON.stringify(d);})
    .text(tool.text)
    .attr("class", tool.classes);
}

function drawToolboxes(tutorialData) {
  var alltutorials = d3.select("svg.tree").selectAll("g.tutorial").data(tutorialData);
  var newtutorials = alltutorials.append("g");

  toolboxes = newtutorials.attr("class", "toolboxes").attr("transform", function() {return "translate(-10, -2)";});

/*  drawTool(toolboxes, {dx: 15, text: "", classes: "fa move-icon",})
    .on("click", function(d){
      d3.event.stopPropagation();
      tutorialMover.start(d);
    });  */

/*  bullseyes = drawTool(newtutorials, {dx: -22, dy: 38, text:"", classes: "fa fa-bullseye",})
    .on("click", function(d) {
      d3.event.stopPropagation();
      tutorialDepender.finish(d);
    });  */

  drawTool(toolboxes, {dx: 28, dy: 3, text:"", classes: "fa fa-dependency-arrow",})
    .on("click", function (d) {
      d3.event.stopPropagation();
      tutorialDepender.start(d);
    });

  return toolboxes;
}

function addEditHandlers(grid) {
  grid
    .on("click", function() {
//      d3.event.stopPropagation();
      tutorialDepender.reset();
    })
    .on("mousemove", function() {
      tutorialDepender.hover(d3.mouse(this));
      tutorialMover.hover(d3.mouse(this));
    });
}

var tutorialDepender = {
  dependencySource: null,
  init: function(dependencyData) {
    this.dependencyData = dependencyData;
  },

  reset: function() {
    var dep = this.dependencySource;
    this.dependencySource = null;
    d3.select("line.dependencyHover").remove();
    $("body").removeClass("dependency-mode");
    $(".tutorial.dependency-source").attr('class', function(index, classNames) { return classNames.replace(" dependency-source", "");  });
    return dep;
  },

  start: function(d) {
    $("body").addClass("dependency-mode");
    this.dependencySource = d;
    $(".tutorial-" + this.dependencySource.id).attr('class', function(index, classNames) { return classNames + " dependency-source";  });

    d3.select("svg.tree").append("line")
      .attr("class", "dependencyHover")
      .attr("x1", gridDatabaseToDisplay(d).x + 60)
      .attr("y1", gridDatabaseToDisplay(d).y + 30)
      .attr("x2", gridDatabaseToDisplay(d).x + 60)
      .attr("y2", gridDatabaseToDisplay(d).y + 30)
      .attr("stroke", "black");

  },

  hover: function(mouse) {
    var depHov = d3.select("line.dependencyHover");
    if( !depHov.empty()) {
      depHov
        .attr("x2", mouse[0] - 3)
        .attr("y2", mouse[1]); 
    }
  },

  finish: function (d) {
    if (this.dependencySource !== null) {
      var dependencySource = this.dependencySource;
      var existing = this.dependencyData.filter(function (dep) {
        return (dep.source.id === d.id && dep.target.id === dependencySource.id)
          || (dep.target.id === d.id && dep.source.id === dependencySource.id);
      });

      function afterPost() {
        tutorialDepender.reset();
        tutorialMover.reloadData();
        d3.json("/dependencies?format=json", function(error, data) {
          window.tutorialDepender.dependencyData = data;
          window.tutorialMover.dependencyData = data;
          drawLines(data);
        });

      }

      if (existing.length !== 0) {
        var dep = existing[0];
        $.post("/dependencies/" + dep.id + "/delete", {}, afterPost);
      } else {
        $.post("/dependencies/new", {"new.tutorialId": this.dependencySource.id, "new.dependencyId": d.id}, afterPost);
      }
    }
  },
};

var tutorialMover = {
  moveTarget: null,

  reset: function() {
    var target = this.moveTarget;
    this.moveTarget = null;
    return target;
  },

  init: function(grid, tutorialData, dependencyData) {
    this.tutorialData = tutorialData;
    this.dependencyData = dependencyData;
  },

  reloadData: function() {
    d3.json("/tutorials?format=json", function(error, data) {
      data.sort(function(a,b) { return d3.ascending(parseInt(a.id), parseInt(b.id)); });
      this.tutorialData = data;
    });
    d3.json("/dependencies?format=json", function(error, data) {
      console.log("reloading data");
      this.dependencyData = data;
    });
  },

  start: function (d) {
    this.moveTarget = d;
    $(".tutorial-" + this.moveTarget.id).attr('class', function(index, classNames) {
      //addClass doesn't work on SVG elements
      return classNames + ' dragging';
    });
  },

  finish: function(mouse) {
    if (this.moveTarget !== null) {
      console.log("finish tutorialMover");
      var p = gridDisplayToDatabase(mouse);
      $.post("/tutorials/" + this.moveTarget.id + "/move", {"move.x": p.x , "move.y": p.y})
         .done(function() {
           var date = new Date();
           $("#saving-status .timeago").html("Last save at " + date.toLocaleString());
         })
         .fail(function() {
           $("#saving-status").html("Error saving - refresh page.");
           $("body").addClass("error error-saving");
         })
         .always(function() {
           console.log("now you can close the page");
         });

      $(".tutorial-" + this.moveTarget.id).attr('class', function(index, classNames) {
        //removeClass doesn't work on SVG elements
        return classNames.replace('dragging', '');
      }); 
        
      this.moveTarget = null;

    }
  },

  hover: function(mouse) {
    if(this.moveTarget !== null) {
      
      this.moveTarget.hasDragged = true;

      var mousePos = gridDisplayToDatabase(mouse);
      if(!(this.moveTarget.x === mousePos.x && this.moveTarget.y === mousePos.y)) {
        var id = this.moveTarget.id;
        $.each(this.dependencyData, function(i, dep) {
          if(dep.source.id === id) {
            dep.source.x = mousePos.x;
            dep.source.y = mousePos.y;
          }
          if(dep.target.id === id) {
            dep.target.x = mousePos.x;
            dep.target.y = mousePos.y;
          }
        });
        $.each(this.tutorialData, function(i, tut) {
          if(tut.id === id) {
            tut.x = mousePos.x;
            tut.y = mousePos.y;
          }
        });
        this.moveTarget.x = mousePos.x;
        this.moveTarget.y = mousePos.y;
        drawLines(this.dependencyData);
        drawTutorials(this.tutorialData);
      }
    }
  },
};
