/*
* Repertoire faceting example visualization widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 10/2009
*
* Requires jquery 1.3.2+ & protovis-3.0
*
* N.B. These examples build on the widget framework - consult the API documentation.
*      They are included for illustrative purposes only, not as finished products.
*
* N.B. Javascript 1.8 expression closures from the Protovis examples have been left,
*      since Safari doesn't support them.
*/

(function($) {
	
	repertoire = repertoire || {};

  //
  // TODO: Desirable features.
  //       - OR-style facets better fit most of the visualizations here
  //       - set range for widget values once and retain while drilling down to maintain context
  //           { OR-style widgets would address this too }
  //       - graphs are diverse enough it may be preferable to provide protovis "hooks" rather than widgets
  //           { standard modifications to marks based on current refinements (e.g. alpha value for selected)
  //             clickable areas, and standard event handlers; standard access to [value, count] pairs }
	
	//
	// Donut facet visualization 
	//
	// Options: As for facet value count widget, plus
	//   - height
	//   - width
	//   - thickness
	//
	repertoire.donut_facet = function($facet, options) {
		var self = repertoire.facet($facet, options);
    
    var $template_fn = self.render;
    self.render = function(counts) {
      var $markup       = $template_fn([]);
      var values_canvas = $markup.find('.facet .values')[0];
      
      var w = options.width,
          h = options.height,
          r = w / 2,
          t = options.thickness,
          a = pv.Scale.linear(0, pv.sum(counts, function(d) { return d[1] }))
                      .range(0, 2 * Math.PI);

      var vis = new pv.Panel()
          .canvas(values_canvas)
          .height(h).width(w);

        vis.add(pv.Wedge)
          .data(counts)
          .bottom(w / 2)
          .left(w / 2)
          .innerRadius(r - t)
          .outerRadius(r)
          .angle(function(d) { return a(d[1]) })
          .title(function(d) { return d[0] + ': ' + d[1] + ' nobelists' })
          .event("click", function(d) {
            var filter = self.refinements(self.facet_name());
            self.toggle(filter, d[0]);
            self.state_changed();
            return false;
          }).cursor("pointer")
        .anchor("outer").add(pv.Label)
          .textMargin(t + 5)
          .text(function(d) { return d[0] });

      vis.render();
      
      return $markup;
    };

  	// end of faceting widget factory method
  	return self;
	};
	
	// Donut facet plugin
	$.fn.donut_facet = repertoire.plugin(repertoire.donut_facet);
	$.fn.donut_facet.defaults = {
	  height:    300,
	  width:     300,
	  thickness: 30
	};
	
	
	//
	// Bar chart facet visualization 
	//
	// Options: As for facet value count widget, plus
	//   - height
	//   - width
	//   - thickness
	//
	repertoire.bar_facet = function($facet, options) {
		var self = repertoire.facet($facet, options);
    
    var $template_fn = self.render;
    self.render = function(counts) {
      var $markup       = $template_fn([]);
      var values_canvas = $markup.find('.facet .values')[0];

      var w = options.width,
          h = options.height,
          x = pv.Scale.ordinal(pv.range(counts.length)).splitBanded(0, w, 3/5),
          y = pv.Scale.linear(0, pv.max(counts, function(d) { return d[1] }))
                      .range(0, h);
      
    	var vis = new pv.Panel()
          .canvas(values_canvas)
          .width(w).height(h);
          
         vis.add(pv.Bar)
          .data(counts)
          .bottom(0)
          .width(x.range().band)
          .height(function(d) { return y(d[1]) })
          .left(function() { return x(this.index) })
         .event("click", function(d) {
            var filter = self.refinements(self.facet_name());
            self.toggle(filter, d[0]);
            self.state_changed();
            return false;
           }).cursor("pointer")
         .anchor("top").add(pv.Label)    
          .textAlign("center").textStyle("#fff")
          .text(function(d) { return d[1] })
         .anchor("bottom").add(pv.Label)
          .textAlign("top").textStyle("#555")
          .textBaseline("bottom")
          .textMargin(x.range().band / 2 + 3)
          .textAngle(-Math.PI / 2)
          .text(function(d) { return d[0] });         

      vis.render();
      
      return $markup;
    };

  	// end of faceting widget factory method
  	return self;
	};
	
	// Bar facet plugin
	$.fn.bar_facet = repertoire.plugin(repertoire.bar_facet);
	$.fn.bar_facet.defaults = {
	  height:    200,
	  width:     300,
	  thickness: 30
	};
	
	
	//
	// Scatter chart facet visualization 
	//
	// Options: As for facet value count widget, plus
	//   - height
	//   - width
	//   - max
	//
	repertoire.scatter_facet = function($facet, options) {
		var self = repertoire.facet($facet, options);
    
    var $template_fn = self.render;
    self.render = function(counts) {
      var $markup       = $template_fn([]);
      var values_canvas = $markup.find('.facet .values')[0];

      var w = options.width,
          h = options.height - 30,
          x = pv.Scale.ordinal(pv.range(counts.length)).splitBanded(0, w, 3/5),
          y = pv.Scale.linear(0, options.max || pv.max(counts, function(d) { return d[1] }))
                      .range(0, h);
      
    	var vis = new pv.Panel()
          .canvas(values_canvas)
          .width(w).height(h)
          .top(10).bottom(20);
        
          vis.add(pv.Rule)
          .data(pv.range(y.domain()[1]))
          .bottom(y)
          .strokeStyle("rgba(0, 0, 0, .04)");

      var dots = vis.add(pv.Dot)
          .data(counts)
          .bottom(function(d) { return y(d[1]) })
          .left(function() { return x(this.index) })
          .strokeStyle("orange").fillStyle("white")
          .title(function(d) { return d[0] + ': ' + d[1] + ' nobelists' });
          
         dots.anchor("top").add(pv.Label)
          .textStyle("rgba(0, 0, 0, .3)")
          .text(function(d) { return d[1] });
          
         dots.add(pv.Label)
          .bottom(-5)
          .textAlign("center")
          .textBaseline("top")
          .text(function(d) { return d[0]; });
          
         dots.event("click", function(d) {
            var filter = self.refinements(self.facet_name());
            self.toggle(filter, d[0]);
            self.state_changed();
            return false;
          }).cursor("pointer");

      vis.render();
      
      return $markup;
    };

  	// end of faceting widget factory method
  	return self;
	};
	
	// Line facet plugin
	$.fn.scatter_facet = repertoire.plugin(repertoire.scatter_facet);
	$.fn.scatter_facet.defaults = {
	  height:    200,
	  width:     300
	};
	
})(jQuery);