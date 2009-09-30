/*
* Repertoire faceting default/example ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3 & jquery.eventdelegation (see end of this file)
*/

// TODO
// - make event delegates pluggable and DRY them out

// - disallow null in nesting            [-2]  DONE
// - search                              [-1] DONE
// - results panel                       [0]  DONE
// - sending facet refinements to server [1]  DONE
// - deselecting on nesting summary      [2]  DONE
// - number facets & null data values not selecting [3]  DONE
// - weird behavior for multi-valued facets [3.5]
// - clear all                           [4]
// - spinner                             [5]
// - support for metadata plugin         [5.5]
// - code clean up                       [6]
// - scalability example                 [7]
// - documentation                       [8]
// - nested facets need to show refinement DONE
// - event handlers for clicking on a facet  DONE
// - changing refinements show trigger event  DONE
// - title defaults not coming through  DONE
// - nested facets not coming through webservice DONE


//
// Usage:
//
// Create a surrounding div with the class 'facet_refinement_context', to define the scope of the current query.
// Within it, invoke facet() to declare divs that display counts and allow refinement, per-facet.  Likewise, invoke
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
    var calc_defaults = {
      title: capitalize(facet),
      facet: facet,
      url: url
    }
    // plugin defaults + calculated defaults + options
    var $settings = $.extend({}, $.fn.facet.defaults, calc_defaults, $$options);
    return this.each(function() {
      var $facet = $(this);
      var $context = context($facet);
      // element specific options
      var o = $.meta ? $.extend({}, $settings, $facet.data()) : $settings;
      // register to listen to refinement change events
      $context.bind('facet_refinements.change', function() {
        update($facet, o);
      });
      
      // TODO.  move this logic into something pluggable
      
      // register to listen to user clicks on facet values
      $facet.delegate('click', o.value_selector, function () {
        // extract facet value that was clicked
        var value = $(this).attr('data');
        var filter = refinements($facet, o.facet);
        if (!value) throw "Value element does not have data attribute";
        toggle(filter, value);
        trigger_refinements_changed($facet);
      	return false;
      });
      $facet.delegate('click', '.nesting_context', function() {
        var level = $(this).attr('level');
        var filter = refinements($facet, o.facet);
        if (!level) throw "Nesting context element does not have level attribute";
        filter.splice(level);
        trigger_refinements_changed($facet);
      	return false;
      });
      // initialize with data
      update($facet, o);
    });
    
    //
    // update facet value counts and repaint the view
    //
    function update($this, opts) {
      console.log('Updating ' + opts.facet + ': ' + refinements($this, opts.facet));
      
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
      var filter = refinements($this, opts.facet);
      var markup = $.fn.facet.format_facet(counts, filter, opts);
      $this.html(markup);
    }
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
  // format an entire facet, any controls, & its value counts
  //
  // if you redeclare: value_selector defaults must be changed according to your markup
  //                   this element must have an attribute 'data' that holds the actual facet value
  //
  $.fn.facet.format_facet = function(counts, refinements, opts) {
	  // format individual facet value, count pairs
		var lis = $.map(counts, function(e) {
			var value    = e[0];
			var count    = e[1];
  		var sel      = selected(refinements, value);
  		return $.fn.facet.format_facet_value(value, count, sel, opts);
	  });
	
	  // format facet container
	  var markup = '<ul class="facet"><div class="title">' + opts.title + '</div>';
	  var nest_elems = '';
	  if (opts.nested) {
	    // TODO.  factor nesting code out
	    markup = markup + '<div class="nesting">';
	    nest_elems = $.map(refinements, function(v, i) {
	      return '<span class="nesting_context selected" level="' + i + '">' + v + '</span>';
	    });
	    markup = markup + nest_elems.join(opts.nesting_delim) + '</div>';
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
    // TODO.  move this logic elsewhere... separate formatter for nested?
    if (opts.nested && !value) return
    
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
  // support functions available to both widgets
  //
  
  //
  // return this current refinement state, for a single facet or all facets
  //
  function refinements($this, facet) {
    var $context = context($this);
    var filter = $context.data("facet_refinements");
    
    // set up refinements for all facets on first access
    if (!filter) {
      filter = {};
  		$context.data('facet_refinements', filter);
    }
    
    // return entire set, or set up specific facet
    if (!facet) {
      return filter;
    } else {
      // set up refinements for this facet
      if (!filter[facet])
        filter[facet] = [];

      return filter[facet];
    }
  }
  
  //
  // clear a facet's refinements, or the entire set
  //
  function clear_refinements($this, facet) {
    var $context = context($this);
    
    if (!facet)
      $context.data('facet_refinements', {});
    else
      refinements($this, facet).length = 0;
  }
  
  //
  // trigger a 'facet refinements changed' event to reload this faceting context
  //
  function trigger_refinements_changed($this) {
    var $context = context($this);
	  $context.trigger('facet_refinements.change');
  }
  
  
  //
  // return the element that binds together this collection of facets' context
  //
  function context($this) {
    return $this.closest(".facet_refinement_context");
  }
  
  //
  // return true/false depending if a value is selected
  //
  function selected(refinements, value) {
    return ($.inArray(value, refinements) > -1)
  }
  
  //
  // toggles whether facet value is selected
  //
  function toggle(refinements, value) {
    var index = $.inArray(value, refinements);
    
    if (index == -1)
      refinements.push(value);
    else
      refinements.splice(index,1);
    
    return refinements;
  }
  
  //
  // capitalize and return a string
  //
  function capitalize(s) {
    return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
  }
  
  
  //
  // An exact implementation of Merb's query string generator.
  // While there is some similarity to jquery's default behavior, implemented here for stability across versions.
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