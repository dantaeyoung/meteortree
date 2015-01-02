function drawCreate(tutorialData) {
  $("button.create-button").on("click", function() {
    window.location.hash = "#create";

    if (window.isLoggedIn && window.location.hash === "#create") {
      $("body").addClass("create-mode");
      var grid = d3.select("svg.tree");
      tutorialCreator.init(grid, tutorialData);

      grid
        .on("click", function() {
          tutorialCreator.create(d3.mouse(this));
        })
        .on("mousemove", function() {
          tutorialCreator.hover(d3.mouse(this));
        });
    }
  });
}

tutorialCreator = {
  feedback: null,

  create: function(mouse) {
    var p = gridDisplayToDatabase(mouse);

    $.post("/tutorials/new", {"new.x": p.x , "new.y": p.y}, function(d) {
      window.location.hash = "";
      $("body").removeClass("create-mode");
      d3.json("/tutorials?format=json", function(error, data) {

        data.sort(function(a,b) { return d3.ascending(parseInt(a.id), parseInt(b.id)); });
        this.tutorialData = data;
        drawTutorials(this.tutorialData);

        var grid = d3.select("svg.tree");
        tutorialMover.init(grid, tutorialData, tutorialMover.dependencyData) 
        addEditHandlers(grid);
        drawToolboxes(tutorialData);

      });

      $(".tutorial-create-feedback").remove();

      console.log("created Tutorial");

    });
  },

  init: function(grid, tutorialData) {
    this.tutorialData = tutorialData;
    this.feedback = grid.append("image")
      .attr("class", "tutorial-create-feedback")
      .attr("xlink:href", tutorialDefaultIconPath)
      .attr("width", 60).attr("height", 60)
      .attr("x", -100)
      .attr("y", -100)
  },

  hover: function(mouse) {
    var gridPos = gridDisplayToDatabase(mouse);

    var overlaps = this.tutorialData.filter(function(t) {
      return (t.x == gridPos.x) && ((t.y == gridPos.y - 1) || (t.y == gridPos.y) || (t.y == gridPos.y + 1));
    });

    if (overlaps.length !== 0) {
      this.feedback.attr("opacity", 0);
    } else {
      this.feedback.attr("opacity", 0.2);
      var p = gridDatabaseToDisplay(gridPos);
      this.feedback.attr("x", p.x) .attr("y", p.y);
    }
  }
};
