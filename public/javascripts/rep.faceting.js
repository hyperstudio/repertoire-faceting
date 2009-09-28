/*
* Repertoire faceting default/example ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*/

(function($) {
  //
  // Usage:
  //
  // Create a surrounding div with the class 'facet_refinement_context', to define the scope of the current query.
  // Within it, invoke facet() to declare a div that displays facet counts and allows refinement.  Likewise, invoke
  // results() to declare a div that display the results of the faceted query.
  //
  // Basic Example:
  //   [ faceting over all plays, with two facets defined (genre and era) ]
  //
  // $().ready(function() { 
  //   $("#play_genre_facet").facet('genre', '/projects/counts/genre');
  //   $("#play_era_facet").facet('era', '/projects/counts/era', { 'title' : 'Time Period' });
  //   $("#play_results").results('/projects/results', {});
  // });
  //
  // ...
  //
  // <div class='facet_refinement_context' id='projects'>
  //    <div id='play_genre_facet'></div>
  //    <div id='play_era_facet'></div>
  //    <div id='play_results'></div>
  // </div>
  //
  // TODO. Later versions may add provisions for the following options:
  //   - facet values sorted alphabetically or by count
  //   - minimum required count for a facet value to be displayed
  //   - whether facet allows multiple or only one selected value
  //   - whether facet requires a value always be selected
  // 
  $.fn.facet = function($$options) {
    // plugin defaults + options
    var $settings = $.extend({}, $.fn.facet.defaults, $$options);
    return this.each(function() {
      var $form = $(this);
      // element specific options
      var o = $.meta ? $.extend({}, $settings, $form.data()) : $settings;


      // initialize and setup submit button
      initialize($form, o, false);
      // install event handlers to validate single fields when they lose focus
      $form.find(':input').blur(function() {
        // determine if field delegates to another and locate the feedback element
        var field = canonical_field($form, $(this), o);
        // remove existing feedback during server activity
        field.$feedback.empty();
        // core operation: submit form via ajax and update field feedback with formatted errors
        validate_form($form, field.$feedback, o, function(data) {
          disabled = data !== true
    	    set_disabled($form, data !== true, o);
      	  set_feedback(field.$feedback, data[field.name], o);
        });
      });
      
    });
  };

  //
  // format counts.  pass in an array of facet values and counts, and the current refinements for that facet
  //
  $.fn.facet.format_facet = function(counts, refinements, opts) {
	  // format individual facet value, count pairs
		var lis = $.map(counts, function(e) {
			var selected = (refinements[e.label] != undefined);
	  	return '<li class="' + (selected ? 'value selected' : 'value') + '">' +
	           '<div class="count">' + e.count + '</div>' + 
	           '<div class="label">' + e.label + '</div></li>'); 
	  });
	
	  // format facet container
	  return '<ul class="facet"><div class="title">' + opts.title + '</div>' + lis.join('') + '</ul>';
  };

  //
  // option defaults
  //
  $.fn.facet.defaults = {
	  title:         null,                     /* title for facet; derived from facet name if not given */
    spinner:       'spinner',                /* css class to add to facet during ajax processing */
  };

  // internal helper functions

  // submit validation info to web service while displaying spinner
  function validate_form($form, $feedback_elem, opts, callback) {
    $feedback_elem.addClass(opts.spinner);
    // submit the form contents to the validation web service
    $form.ajaxSubmit({
  	  url: opts.url,
  	  type: opts.type,
  	  dataType: 'json',
    	beforeSend: function(xhr) { xhr.setRequestHeader("Accept", "application/json") }, /* JQuery uses wrong content type header */
  	  success: function(data) {
  	    // remove spinner and yield result to callback
    	  $feedback_elem.removeClass(opts.spinner);
    	  callback(data);
  	  } 
  	});    
  }
})(jQuery);
