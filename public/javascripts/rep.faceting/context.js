/*
* Repertoire faceting ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
*
* Register an element as the faceting context,
*   and provide user data extraction function
*
* Handles:
*       - grouping faceting widgets into shared context
*       - hooks for managing custom data
*/ 

//= require <jquery>

$.fn.facet_context = function(state_fn) {
  return this.each(function() {
    $context_elem = $(this);
    $context_elem.addClass('facet_refinement_context');
    $context_elem.data('facet_state_fn', state_fn);
  });
};