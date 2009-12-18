/*
* Repertoire faceting ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 12/2009
*
* Requires jquery 1.3.2+, OpenLayers 2.8
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
* Earth browser widget for GIS-based facets
*
* Usage:
*    
*     $('#birthplace_geom').earth_facet(<options>)
*
* Note!
*     You must activate Google's API by including a <script> tag
*     with your API key in the page head.
*
* Options:
*
*     As for default facet widget, plus
*     - delim: delimiter between layer nesting levels
*     None are required.
*/

//= require "../facet"

//= provide "../../../images/repertoire-faceting/proportional_symbol.png"

//= require <google-earth-extensions>


// bootstrap Google Earth API
if (!google)
  throw "You must load the Google AJAX API in a <script> element";

google.load("earth", "1");

// define the Earth faceting widget
repertoire.earth_facet = function($facet, options) {
  var self = repertoire.facet($facet, options);
  
  // private record of refinements to date
  var history = [];
  
  // initial model, stored until Earth initializes
  var initial_counts_stash = null;

  // Google Earth API
  var earth    = null;
  var earth_ex = null;
  
  // when initialized, render empty widget, add nesting status and attach Earth
  var super_render = self.render;
  var $template = super_render([]);
  var $nesting  = $('<div class="nesting"></div>');
  $template.find('.values').before($nesting);
  $facet.html( $template );
  
  var facet_values_elem = $facet.find('.values')[0];
  google.earth.createInstance(facet_values_elem, post_earth_init, function() {
    throw "Google Earth setup failed";
  });
  
  // remainder of setup occurs after Earth has initialized
  function post_earth_init(object) {
    earth    = object;    
    earth_ex = new GEarthExtensions(earth);

    // set up Earth visual appearance
    earth.getWindow().setVisibility(true);
    earth.getNavigationControl().setVisibility(earth.VISIBILITY_AUTO);
    // earth.getOptions().setStatusBarVisibility(true);
       
    if (options.camera) {
      var viewPoint = earth_ex.dom.buildPoint([options.camera.lat, options.camera.lon, options.camera.altitude]);
      var lookAt    = earth_ex.dom.buildCamera(viewPoint, { tilt: options.camera.tilt });
      earth.getOptions().setFlyToSpeed(options.camera.speed);  
      earth.getView().setAbstractView(lookAt);
    }

    // listen for facet refinements on displayed features in Earth
    google.earth.addEventListener(earth.getWindow(), 'click', function(event) {
      var range     = earth.getView().copyAsLookAt(earth.ALTITUDE_RELATIVE_TO_GROUND).getRange();
      var target    = event.getTarget();
      var type      = target.getType();
      var id        = target.getId();
      
      var context = self.context();
      var filter  = context.refinements(self.facet_name());
      var frame;
      
      // below a certain altitude/range, user has switched from faceting to exploration
      if (range < options.refinement_range)
        return;
      
      // handle clicks on one of our placemarks
      //    but if already selected, let user drag globe instead
      if (type == 'KmlPlacemark' && id != filter[0]) {
        frame     = {
          'key'     : target.getId(),
          'label'   : target.getName().replace(/\s*\d*$/, ''),
          'kml'     : target.getKml(),
          'cur_view': earth_ex.view.serialize()
        };
          
      // clicks on globe itself clear the refinements
      } else if (type == 'GEGlobe' && history.length > 0) {
        // TODO.  known issue: when two points share the same space and GE must "scatter" to allow a user click
        //        GEGlobe receives the event -- should defer to GEGlobe in this case
        frame = null; 
        earth_ex.view.deserialize(history[0].cur_view);
      
      // all other events handled by GE
      } else { return }

      // refine to object while flying to conceal ajax latency
      if (frame) { earth_ex.util.flyToObject(target); }
      refine_to(frame);

      // consume event
      event.preventDefault();
    });
    
    // if first load occurred before Earth ready, render now
    if (initial_counts_stash) {
      self.render(initial_counts_stash);
      initial_counts_stash = null;
    }
    
    // reload now that plugin is available
    self.reload();
  }

  //
  // refine or expand this facet to the provided value; pass in null/undefined to clear
  //
  function refine_to(frame) {
    // update shared facet refinement context
    var context = self.context();
    var filter  = context.refinements(self.facet_name());
    var level   = -1;
    
    // if already refined to this feature, pass
    if (frame && filter[0] == frame.key)
      return;
    
    filter.length = 0;
    // if not clearing refinements entirely, update history
    if (frame && frame.key) {

      // expanding out in history
      for (var i = 0; level < 0 && i < history.length; i++) {
        if (history[i].key == frame.key) {
          level = i;
          frame = history[i];
        }
      }
      
      // refining to new feature
      if (level < 0) {
        level = history.length;
        history[level] = frame;
      }
      
      // set current context appropriately
      filter[0] = frame.key;
    }
    
    // prune history if necessary
    history.splice(level+1);
    
    // reload all associated facet widgets
    context.trigger('changed');
  }
  
  //
  // toggle facet value selection after a user click on its feature
  //
  self.handler('click!.rep .facet .nesting_level', function() {
    // extract the nesting level to clear beyond
    var level = $(this).data('facet_nesting_level');
    if (level === undefined) throw "Nesting context element does not have level data";
    
    earth_ex.view.deserialize(history[level].cur_view);
    
    if (level > 0)
      refine_to(history[level-1]);
    else
      refine_to(null);
    
    // reset refinement for this facet to last feature key in history
    return false;
  });
  
  //
  // Reload the facet value counts for this widget
  //
  var super_reload = self.reload;
  self.reload = function(callback) {
    // format nesting summary
    var $nesting = $($facet).find('.nesting').empty();
  
    // collect element for each history level
    var $elems   = $.map(history, function(v, i) {
      var $elem  = $('<span class="nesting_level selected">' + v.label + '</span>');
      $elem.data('facet_nesting_level', i);
      return $elem;
    });

    // inject into summary interspersed with delimiter
    $.each($elems, function(i, e) {
      $nesting.append(e);
      if (i < $elems.length-1)
        $nesting.append(options.delim);
    });
    
    super_reload(callback);
  }
  
  //
  // when the faceting context updates with new counts, replace the Earth
  // features with the new set of geometries, colored into a choropleth map
  //
  self.render = function(results) {
    // if google earth not available yet, stash model and wait to render
    if (!earth) {
      initial_counts_stash = results;
      return;
    }
    
    // erase current Earth state
    earth_ex.dom.clearFeatures();
    
    // create shells for features in history
    // [ done afterward so features get events before history]
    $.each(history, function(index, value) {
      var kml      = value.kml;
      var geometry = earth.parseKml(kml);
      // reset the feature to history styling
      earth_ex.dom.walk({
          rootObject: geometry,
          visitCallback: function() {
            if ('getType' in this && this.getType() == 'KmlPlacemark')
              this.setStyleUrl('#history_feature');
          }
        });
      earth.getFeatures().appendChild(geometry);
    });
    
    // define global styles
    var styleProlog = kmlStyleProlog();
    earth.getFeatures().appendChild( kmlDocument([styleProlog]) );

    // create a set of choropleth KML features based on the facet value counts
    // N.B. this function assumes the data is already in descending count order!
    // format of facet values: [ key, count, label, KML ]
    var counts    = $.map(results, function(value) { return value[1] });
    var max_count = Math.max.apply( Math, counts );
    var q_fn      = quantile_fn(counts, options.quantiles.categories);
    
    // generate KML placemarks for each feature count value
    $.each(results, function(index, value) {
      var checksum      = value[0];
      var count         = value[1];
      var label         = value[2];
      var display_kml   = value[3];
      var geometry_type = value[4];
      var label_kml     = value[5];
      
      // if data faulty, skip the record
      if (!checksum || !display_kml || !geometry_type || !label_kml ||!label) {
        // console.log('Error: ' + checksum + ':' + label + ':' + label_kml + ':' + display_kml.length);
        return;
      }

      // compute the weighted color for this element by quantile      
      var quant_fract = q_fn(count);
      
      // create and add placemark for kml
      var placemark = kmlPlacemark(checksum, count, max_count, label, display_kml, geometry_type, label_kml, quant_fract);
      var document  = kmlDocument(placemark);
      earth.getFeatures().appendChild(document);
    });
  }
  
  function kmlDocument(content) {
    var kml = 
    '<?xml version="1.0" encoding="UTF-8"?>' +
    '<kml xmlns="http://www.opengis.net/kml/2.2">' +
    '<Document>' +
    content +
    '</Document>' +
    '</kml>';
    
    return earth.parseKml(kml);
  }
  
  function kmlStyleProlog() {
    var kml = 
    '<Style id="history_feature">' +
      '<IconStyle><Icon></Icon></IconStyle>' +
      '<LabelStyle><color>00ffffff</color></LabelStyle>' +
      '<LineStyle><color>' + options.style.line.color + '</color>' + 
                 '<width>' + options.style.line.width + '</width></LineStyle>' +
      '<PolyStyle><fill>0</fill><outline>1</outline></PolyStyle>' +
      '<BalloonStyle><displayMode>hide</displayMode></BalloonStyle>' +
    '</Style>' +
    '<Style id="proportional_feature">' +
      '<IconStyle>' +
        '<Icon><href>' + absolute_url('/images/repertoire-faceting/proportional_symbol.png') + '</href></Icon>' +
        '<hotSpot x="0.5"  y="0.5" xunits="fraction" yunits="fraction"/>' +
        '<color>' + options.quantiles.low + '</color>' +
      '</IconStyle>' +
      '<PolyStyle><fill>0</fill><outline>1</outline></PolyStyle>' +
    '</Style>' +
    '<Style id="normal_choropleth_feature">' +
      '<IconStyle><Icon></Icon></IconStyle>' +
      '<LabelStyle><color>00ffffff</color></LabelStyle>' +
      '<LineStyle><color>' + options.style.line.color + '</color>' + 
                 '<width>' + options.style.line.width + '</width></LineStyle>' +
      '<PolyStyle><fill>1</fill><outline>1</outline></PolyStyle>' +
    '</Style>' +
    '<Style id="highlight_choropleth_feature">' +
      '<IconStyle><Icon></Icon></IconStyle>' +
      '<LabelStyle><color>' + options.style.label.color + '</color></LabelStyle>' +
      '<LineStyle><color>' + options.style.line.color + '</color>' + 
                 '<width>' + options.style.line.width + '</width></LineStyle>' +
      '<PolyStyle><fill>1</fill><outline>1</outline></PolyStyle>' +
    '</Style>' +
    '<StyleMap id="choropleth_feature">' +
      '<Pair><key>normal</key><styleUrl>#normal_choropleth_feature</styleUrl></Pair>' +
      '<Pair><key>highlight</key><styleUrl>#highlight_choropleth_feature</styleUrl></Pair>' +
   '</StyleMap>';
   
   return kml;
  }
  
  function kmlPlacemark(checksum, count, max_count, label, display_kml, geometry_type, label_kml, quant_fract) {
    var color = earth_ex.util.blendColors(options.quantiles.low, options.quantiles.high, quant_fract);
    var scale = Math.sqrt(count / max_count) * 1.8 + 0.2;
    
    var kml =   
    '<Placemark id="' + checksum + '">' +
      '<name>' + label + ' ' + count + '</name>' +
      '<description>' + label + ' ' + count + '</description>';
      
    if (geometry_type == 'POINT') {
      kml = kml +
        '<styleUrl>#proportional_feature</styleUrl>' +
        '<Style><IconStyle>' +
        '<scale>' + scale + '</scale>' +
        '</IconStyle></Style>' +
        display_kml;
      
    } else {
      kml = kml + 
        '<styleUrl>#choropleth_feature</styleUrl>' +
        '<Style><PolyStyle><color>' + color + '</color></PolyStyle></Style>' +
        '<MultiGeometry>' +
        label_kml +
        display_kml +
        '</MultiGeometry>';
    }
      
    kml = kml +
      '</Placemark>';
    
    return kml;
  }
  
  function quantile_fn(counts, num_quantiles) {
    // n.b. should be called with counts in descending order (as faceting query returns them)
    var bins = calc_splits(counts.reverse(), num_quantiles);
    
    // return closure that accepts value and returns its quantile as a fraction
    return function(val) {
      for (var i=0; i < bins.length; i++) {
        if (bins[i] >= val) {
          return i / bins.length;
        }
      }
      return 1.0;
    };
    
    // calculate the splits between items the same quantile
    function calc_splits(items, m) {
      var result = [];
      var split;
      for (var i=1; i <= m; i++) {
        split = nth_split(items, i, m);
        result.push(split);
      }
      return result;
    }
    
    // this algorithm for quantile function is borrowed from David Richard's sirb (Ruby) library
    function nth_split(items, n, m) {
      var dividers = m - 1;
      var i, j;
      if (items.length % m == dividers) {                 // divides evenly
        // because we have a 0-based list, we get the floor
        i = Math.floor((items.length / m) * n);
        j = i
      } else {
        i = ((items.length / m) * n) - 1;
        i = i > (items.length / m) ? Math.floor(i) : Math.ceil(i);
        j = i + 1;
      }
      if (j < items.length)
        return items[i] + ((n / m) * (items[j] - items[i]));
      else
        return items[items.length - 1];
    }
  }
  
  function absolute_url(url) {
    if (repertoire.defaults.path_prefix)          
      url = repertoire.defaults.path_prefix + url;
          
    return 'http://' + window.location.hostname + ':' + window.location.port + url;
  }
  
  return self;
}

// GIS facet plugin
$.fn.earth_facet = repertoire.plugin(repertoire.earth_facet);
$.fn.earth_facet.defaults = $.extend({}, $.fn.nested_facet.defaults, {
  delim:      '&nbsp;/ ',                                             /* delimiter between layer levels */
  quantiles: { categories: 7, low: "cc507fff", high: "cc00008b" },    /* N.B.! Google Earth uses #aabbggrr */
  style:     {
    label: { color: "ccffffff" },
    line:  { width: 2.5, color: "ccffffff" }
  },
  camera: { lat: 0, lon: 0, tilt: 0, range: 4500000, speed: 1 },
  refinement_range: 6000                           /* user events below this altitude are navigation, not refinement */
});