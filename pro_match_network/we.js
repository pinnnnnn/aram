
// Load the d3.js library from the Web.
require.config({paths:
    {d3: "http://d3js.org/d3.v3.min"}});


require(["d3"], function(d3) {
   // The code in this block is executed when the d3.js library has been loaded.

   // First, we specify the size of the canvas
   // containing the visualization (size of the <div> element).
   var width = 800, height = 800;

   // Create a color scale.
   var color = d3.scale.category10();

   // Create a force-directed dynamic graph layout.
   var force = d3.layout.force()
     .charge(-100)
     .linkDistance(300) //function(d) { return  (1 / d.weight) * 200; })
     .size([width, height]);

   // In the <div> element, we create a <svg> graphic
   //   that will contain our interactive visualization.
   var svg = d3.select("#we_graph").select("svg");

   if (svg.empty()) {
     svg = d3.select("#we_graph").append("svg")
           .attr("width", width)
           .attr("height", height);
   };


  // Load the JSON file.
  d3.json("we.json", function(error, graph) {
    // In this block, the file has been loaded
    //   and the 'graph' object contains our graph.

    // Load the nodes and links in the force-directed graph.
    force.nodes(graph.nodes)
      .links(graph.links)
      .start();


    // Create a <line> SVG element for each link
    //   in the graph.
    var link = svg.selectAll(".link")
      .data(graph.links)
      .enter().append("line")
      .attr("class", "link")
      .attr("stroke-width", function(d) { return d.weight * 2 ; });


    // Create a <circle> SVG element for each node
    //   in the graph, and we specify a few attributes.
    var node = svg.selectAll(".node")
      .data(graph.nodes)
      .enter().append("circle")
      .attr("class", "node")
       // Radius of the nodes are determined by the number of times a champ was picked
      .attr("r", function(d) { return Math.sqrt(d.appearance) * 5; })
      .style("fill", function(d) {
         // The node color depends on the position.
         return color(d.position); })
      .call(force.drag);

    // For each of the node, show the champ name as its label
    var label = svg.selectAll(".mytext")
                    .data(graph.nodes)
                    .enter()
                    .append("text")
                    .text(function (d) { return d.name; })
                    .style("text-anchor", "middle")
                    .style("fill", "#555")
                    .style("font-family", "Arial")
                    .style("font-size", 12);



    // Bind the positions of the SVG elements
    //   to the positions of the dynamic force-directed
    //   graph, at each time step.
    force.on("tick", function() {
      link.attr("x1", function(d){return d.source.x})
          .attr("y1", function(d){return d.source.y})
          .attr("x2", function(d){return d.target.x})
          .attr("y2", function(d){return d.target.y});

      node.attr("cx", function(d){return d.x})
          .attr("cy", function(d){return d.y});

      label.attr("x", function(d){ return d.x; })
          .attr("y", function (d) {return d.y - 10; });
    });


    // Implement the node highlight feature
    node.on("click", function(d) {
        var thisNode = d.index
        var connected = graph.links.filter(function(e) {
            return e.source === thisNode || e.target === thisNode
        });

        link.attr("opacity", function(d) {
            return (d.source.index == thisNode || d.target.index == thisNode) ? 1 : 0.05
        });

        force.nodes(nodes);
    });

    // Implement the cluster feature
    d3.select("#clusterButton").on("click", function () {
        netClustering.cluster(graph.nodes, graph.links);
        svg.selectAll(".node").transition().duration(2000).style("fill", function(d) { return color(d.cluster); });
    });

    // Implement the drag button
    d3.select("#resetButton").on("click", function(){

        link.attr("opacity", 1);

        node.style("fill", function(d) {
         // The node color depends on the position.
                 return color(d.position);
            });
    });

    // Implement the drag feature
    d3.select("#dragButton").on("click", function () {
        force.drag()
            .on("dragstart", function(d) {
                 d3.select(this).classed("fixed", d.fixed = true);
             });
    });
  });
});
