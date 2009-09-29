/*
* Repertoire faceting default/example ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3 & jquery.eventdelegation (see end of this file)
*/

// TODO
// - search                              [-1] DONE
// - results panel                       [0]  DONE
// - sending facet refinements to server [1]  DONE
// - deselecting on nesting summary      [2]
// - number facets & null data values not selecting [3]  DONE
// - clear all                           [4]
// - spinner                             [5]
// - nested facets need to show refinement DONE
// - event handlers for clicking on a facet  DONE
// - changing refinements show trigger event  DONE
// - title defaults not coming through  DONE
// - nested facets not coming through webservice DONE


//
// Usage:
//
// Create a surrounding div with the class 'facet_refinement_context', to define the scope of the current query.
// Within it, invoke facet() to declare divs that display counts and allows refinement, per-facet.  Likewise, invoke
// results() to declare a div that displays the results of the faceted query.
//
// Basic Example:
//   [ faceting over all plays, with two facets defined (genre and era) ]
//
// $().ready(function() { 
//   $("#play_genre_facet").facet('genre', '/projects/counts/genre');
//   $("#play_era_facet").facet('era', '/projects/counts/era', { 'title' : 'Time Period' });
//   $("#play_results").results('/projects/results', {});
// });
// ...
// <div class='facet_refinement_context' id='projects'>
//    <div id='play_genre_facet'></div>
//    <div id='play_era_facet'></div>
//    <div id='play_results'></div>
// </div>
//
// Per facet options:
//    nested: <boolean>                           /* whether to treat values as nested */
//
// Default options:
//   value_selector: <jquery selector>                   /* jquery selector identifying elements that hold facet value counts */
//   nesting_delim: <string>                             /* delimiter between nested facet values */
//   spinner: <css class>                                /* css class to add to facet during ajax processing */
//   error: <string>                                     /* message when ajax request dropped */
//
// Web service conventions:
//   all webservices are accessed by HTTP GET, with parameters encoded Merb-style.  when backed by a merb-json web service
//   it will "just work."  for the exact format, see comments further down
//
//
// TODO. Later versions may add provisions for the following options:
//   - facet values sorted alphabetically or by count
//   - minimum required count for a facet value to be displayed
//   - whether facet allows multiple or only one selected value
//   - whether facet requires a value always be selected
//
(function($) {
  //
  // facet count display and refinement widget
  //
  $.fn.facet = function(facet, url, $$options) {
    // calculated defaults
    var calc_opts = {
      title: capitalize(facet),
      facet: facet,
      url: url
    }
    // plugin defaults + options
    var $settings = $.extend({}, $.fn.facet.defaults, calc_opts, $$options);
    return this.each(function() {
      var $facet = $(this);
      var $context = context($facet);
      // element specific options
      var o = $.meta ? $.extend({}, $settings, $facet.data()) : $settings;
      // register to listen to refinement change events
      $context.bind('facet_refinements.change', function() {
        update($facet, o);
      });
      // register to listen to user clicks on facet values
      $facet.delegate('click', o.value_selector, function () {
        // extract facet value that was clicked
        var value = $(this).attr('data');
        var filter = refinements($facet);
        if (!value) throw "Value element does not have data attribute";
        console.log('toggling ' + o.facet + ':' + value);
        toggle(filter, o.facet, value);
        refinements($facet, filter);
      	return false;
      });
      // initialize with data
      update($facet, o);
    });
  };
  
  //
  // results display widget (no functionality other than update on refinement changes)
  //
  $.fn.results = function(url, $$options) {
    var $settings = $.extend({}, $.fn.results.defaults, $$options);
    return this.each(function() {
      var $results = $(this);
      var $context = context($results);
      // element specific options
      var o = $.meta ? $.extend({}, $settings, $results.data()) : $settings;
      // register to listen to refinement change events
      $context.bind('facet_refinements.change', function() {
        update($results);
      });  
      update($results);
    });

    function update($results) {
      $results.load(url, to_query_string($.fn.facet.data($results)));
    }
  };
  
  //
  // format an entire facet & all its value counts.
  //
  // if you redeclare: value_selector defaults must be changed according to your markup
  //                   this element must have an attribute 'data' that holds the actual facet value
  //
  $.fn.facet.format_facet = function(counts, refinements, opts) {
	  // format individual facet value, count pairs
		var lis = $.map(counts, function(e) {
			var value    = e[0];
			var count    = e[1];
  		var sel      = selected(refinements, opts.facet, value);
  		return $.fn.facet.format_facet_value(value, count, sel, opts);
	  });
	
	  // format facet container
	  var markup = '<ul class="facet"><div class="title">' + opts.title + '</div>';
	  if (opts.nested) {
	    markup = markup + '<div class="nesting">';
	    if (refinements[opts.facet])
	      markup = markup + refinements[opts.facet].join(opts.nesting_delim);
	    markup = markup + '</div>';
	  }
	  markup = markup + '<div class="values">' + lis.join('') + '</div></ul>';
	  
	  return markup
  };
  
  //
  // format a single value count.
  //
  // if you redeclare: value_selector defaults must be changed according to your markup
  //                   this element must have an attribute 'data' that holds the actual facet value
  //
  $.fn.facet.format_facet_value = function(value, count, selected, opts) {
    var label = value || '...';
  	return '<li class="' + (selected ? 'value selected' : 'value') + '" data="' + value + '">' +
           '<div class="count">' + count + '</div>' + 
           '<div class="label">' + label + '</div></li>';
  }
  
  //
  // hook to add app-specific params to webservice callbacks
  //
  $.fn.facet.data = function($this) {
    return {
      filter: refinements($this),
      search: $("#search").val()
    };
  };
  
  //
  // option defaults [ additional configuation: redefine $.fn.facet.format_facet_value, $.fn.facet.format_facet ]
  //
  $.fn.facet.defaults = {
    value_selector: '.facet .value[data]',      /* jquery selector identifying elements that hold facet value counts */
    nesting_delim: ' / ',                       /* delimiter between nested facet values */
    spinner:       'spinner',                   /* css class to add to facet during ajax processing */
    error:         'Could not load'             /* message when ajax request dropped */
  };
  
  $.fn.results.defaults = {
    /* no configuration yet */
  };
  
  //
  // support functions
  //
  // TODO. encapsulate state, so that $this, facet, url, etc always available
  //
  
  function update_results($this, opts) {
    var defaults = {
      url:  opts.url,
      type: 'GET',
  	  dataType: 'html',
    };
    
    $.ajax($.extend({}, defaults, callbacks));
  }
  
  //
  // update facet value counts and repaint the view
  //
  function update($this, opts) {
    console.log(opts.facet + ' updating counts');
    console.log(to_query_string($.fn.facet.data($this)));

    $this.addClass(opts.spinner);
    fetch_counts(opts, {
      data:    to_query_string($.fn.facet.data($this)),
      success: function(counts) {
        $this.removeClass(opts.spinner);
        render($this, counts, opts);
      },
      error:   function() {
        $this.html(opts.error);
      }
    });
  }
  
  //
  // fetch facet value counts and pass to success callback
  //
  function fetch_counts(opts, callbacks) {
    var defaults = {
      url:  opts.url,
      type: 'GET',
  	  dataType: 'json',
    	beforeSend: function(xhr) { xhr.setRequestHeader("Accept", "application/json") } /* JQuery uses wrong content type header */
    };
    
    $.ajax($.extend({}, defaults, callbacks));
  }
  
  //
  // repaint the facet in DOM
  //
  function render($this, counts, opts) {
    var filter = refinements($this);
    var markup = $.fn.facet.format_facet(counts, filter, opts);
    $this.html(markup);
    // install event handlers here
  }
  
  //
  // return this collection of facets' refinement state
  // pass in new refinement to update and trigger a change event
  //
  function refinements($this, data) {
    var $context = context($this);    
    var refinements = $context.data("facet_refinements");
    
    // set to empty on first access
    if ( !refinements && !data ) {
      refinements = {};
  		$context.data('facet_refinements', refinements);
  	}
    
    // update and fire event if necessary  
		if ( data !== undefined ) {
		  $context.data('facet_refinements', data);
		  $context.trigger('facet_refinements.change');
		  refinements = data;
	  }
	  
	  // return current state
	  return refinements;
  }
  
  //
  // return the element that binds together this collection of facets' context
  //
  function context($this) {
    return $this.closest(".facet_refinement_context");
  }
  
  //
  // utility functions
  //
  
  //
  // return true/false depending if a value is selected
  //
  function selected(refinements, facet, value) {
    if (!refinements[facet])
      return false;
    else
      return ($.inArray(value, refinements[facet]) > -1)
    end;
  }
  
  //
  // toggles whether facet value is selected in refinements
  //
  function toggle(refinements, facet, value) {
    if (!refinements[facet])
      refinements[facet] = [];
      
    var index = $.inArray(value, refinements[facet]);
    
    if (index == -1)
      refinements[facet].push(value);
    else
      refinements[facet].splice(index,1);
    
    return refinements;
  }
  
  //
  // capitalize and return a string
  //
  function capitalize(s) {
    return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
  }
  
  
  //
  // This is an exact implementation of Merb's query string generator.  While there is some similarity to jquery's default behavior,
  //   implemented here for stability and completeness.
  //
  //   An example:
  //
  //   Merb::Parse.params_to_query_string(:filter => {:year => [1593, 1597], :genre => ['Tragedy', 'Comedy'] }, :search => 'William')
  //   ==> "filter[genre][]=Tragedy&filter[genre][]=Comedy&filter[year][]=1593&filter[year][]=1597&search=William"
  //
  function to_query_string(value, prefix) {
    if (!prefix) 
      prefix = '';

    if (value instanceof Array) {
      var vs = []
      jQuery.each(value, function(i, v) {
        vs.push(to_query_string(v, prefix + '[]'));
      });
      return vs.join('&');    
    } else if (typeof(value) == "object") {
      var vs = [];
      jQuery.each(value, function(k, v) {
        var item = to_query_string(v, (prefix.length > 0) ? (prefix + '[' + escape(k) + ']') : escape(k))
        vs.push(item);
      });
      return vs.join('&');
    } else {
      return prefix + '=' + escape(value);
    }
  }
    
})(jQuery);


/* 
 * jQuery Event Delegation Plugin - jquery.eventdelegation.js
 * Fast flexible event handling
 *
 * January 2008 - Randy Morey (http://dev.distilldesign.com/)
 */

(function ($) {
	/* setup list of allowed events for event delegation
	 * only events that bubble are appropriate
	 */
	var allowed = {};
	$.each([
		'click',
		'dblclick',
		'mousedown',
		'mouseup',
		'mousemove',
		'mouseover',
		'mouseout',
		'keydown',
		'keypress',
		'keyup'
		], function(i, eventName) {	
			allowed[eventName] = true;
	});
	
	$.fn.extend({
		delegate: function (event, selector, f) {
			return $(this).each(function () {
				if (allowed[event])
					$(this).bind(event, function (e) {
						var el = $(e.target),
							result = false;
						
						while (!$(el).is('body')) {
							if ($(el).is(selector)) {
								result = f.apply($(el)[0], [e]);
								if (result === false)
									e.preventDefault();
								return;
							}
							
							el = $(el).parent();
						}
					});
			});
		},
		undelegate: function (event) {
			return $(this).each(function () {
				$(this).unbind(event);
			});
		}
	});
})(jQuery);