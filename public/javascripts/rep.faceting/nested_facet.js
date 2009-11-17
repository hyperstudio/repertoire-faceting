/*
* Repertoire faceting ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
* Nested facet value widget
*
* Usage:
*    
*     $('#birthplace').nested_facet(<options>)
*
* Options:
*
*     As for default facet widget, plus
*     - delim: delimiter between nesting levels
*     None are required.
*/

//= require "facet_widget"


repertoire.nested_facet = function($facet, options) {
  // inherit complete facet-value-count widget behaviour
  var self = repertoire.facet($facet, options);
  
  self.handler('click!.rep .facet .nesting_level', function() {
    // extract the nesting level to clear beyond
    var level = $(this).data('facet_nesting_level');
    if (level === undefined) throw "Nesting context element does not have level data";
    // get current refinements for this facet
    var filter = self.refinements(self.facet_name());
    // clear all beyond clicked level and update entire context
    filter.splice(level);
    self.state_changed();
    return false;
  });
  
  //
  // Inject nesting level markup into template for facet value count widget
  //
  var $template_fn = self.render;
  self.render = function(counts) {
    var $markup = $template_fn(counts);
    var selected = self.refinements(self.facet_name());
    
    // deselect any values chosen by the default renderer; 
    // nested selections are in line above values
    $markup.find('.selected').removeClass('selected');
    
    // format nesting summary
    var $nesting = $('<div class="nesting"></div>');
    
    // collect element for each level
    var $elems   = $.map(selected, function(v, i) {
      var $elem  = $('<span class="nesting_level selected">' + v + '</span>');
      $elem.data('facet_nesting_level', i);
      return $elem;
    });

    // inject into summary interspersed with delimiter
    $.each($elems, function(i, e) {
      $nesting.append(e);
      if (i < $elems.length-1)
        $nesting.append(options.delim);
    });
    
    // inject the nesting summary directly before the facet values list
    $markup.find('.values').before($nesting);
    
    return $markup;
  };

  // end of faceting widget factory method
  return self;
};

// Nested facet plugin
$.fn.nested_facet = repertoire.plugin(repertoire.nested_facet);
$.fn.nested_facet.defaults = {
  delim: '&nbsp;/ '                       /* delimiter between nesting levels */
};