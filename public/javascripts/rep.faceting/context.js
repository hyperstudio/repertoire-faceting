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
*       - manipulation of faceting refinements
*       - url/query-string construction
*       - data assembly for sending to webservice
*       - change publication and observing
*       - grouping faceting widgets into shared context
*       - facet count/results ajax api
*       - hooks for managing custom data
*/

//= require <jquery>

//= require <rep.widgets/model>

repertoire.facet_context = function(context_name, state_fn, options) {
  var self = repertoire.model(options);
  
  // current query state for all facets in context
  var filter = {};
  
  //
  // Return the current refinements for one facet, or all if no facet given
  //
  // Changes to the returned object are persistent, but you must call self.state_changed()
  // to trigger an update event.
  //
  self.refinements = function(name) {
    if (!name) {
      // if no facet provided, return all
      return filter;
    } else {
      // set up refinements for this facet
      if (!filter[name])
        filter[name] = [];

      // return current refinements
      return filter[name];
    }
  };
  
  //
  // Calculate facet value counts from webservice
  //
  // By default, the url is '/<context>/counts/<facet>'
  //
  self.counts = function(facet_name, callback, $elem) {
    // default url is '<context>/results'
    var url = self.default_url([context_name, 'counts', facet_name]);
    // package up the faceting state and send back to results rendering service
    self.fetch(self.params(), url, 'json', callback, $elem);
  };
  
  //
  // Update query results from webservice
  //
  // By default, the url is '/<context>/counts/<facet>'
  //
  self.results = function(type, callback, $elem) {
    // default url is '<context>/results'
    var url = self.default_url([context_name, 'results']);
    // package up the faceting state and send back to results rendering service
    self.fetch(self.params(), url, type, callback, $elem);
  };
    
  //
  // Return the state for the entire faceting context (group of widgets),
  // with any context-specific additions
  //
  self.params = function() {
    return $.extend({ filter: self.refinements() }, state_fn());
  };

  //
  // Toggle whether facet value is selected
  //
  self.toggle = function(name, item) {
    var values = self.refinements(name);
    var index  = $.inArray(item, values);

    if (index == -1)
      values.push(item);
    else
      values.splice(index, 1);

    return values;
  };
  
  // end of context factory method
  return self;
}

$.fn.facet_context = function(state_fn) {
  return this.each(function() {
    // add locator css class to element, and store faceting context data model in it
    var $elem = $(this);
    var name  = $elem.attr('id');
    var model = repertoire.facet_context(name, state_fn, repertoire.defaults);
    $elem.addClass('facet_refinement_context');
    $elem.data('context', model);
  });
};