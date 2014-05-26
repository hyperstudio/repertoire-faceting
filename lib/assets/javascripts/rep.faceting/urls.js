/*
* Repertoire faceting ajax widgets
*
* Copyright (c) 2014 MIT Hyperstudio
* Christopher York, 05/2014
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
*
* Register a faceting context to control the browser's url bar.
*
* Handles:
*       - updating url bar when context changes
*       - updating context from url bar when user goes back / forward
*       - updating context from url on initial page load
*
* Usage:
*       - attach this plugin to your faceting context *after* declaring
*         all facets etc:
*
*   $('#nobelists').facet_context(function() {
*     return { search: $("#search").val() } }
*   $('.facet').facet();
*   ...
*
*   $('#nobelists').urls(function(json) {
*     $("#search").val(json.search); }
*
*/

//= require deparam

//
// Set up history tracking
//

repertoire.urls = function(context, update_state_fn, options) {

  // navigate to a new url whenever facet refinements change
  context.bind('changed', function(data) {
    if (!data.rerouting) {
      history.pushState({}, '', context.url());
    }
  });

  // copy refinements out of url when user travels in history
  window.onpopstate = function (event) {
    reroute();
  };

  // bootstrap refinements on page load
  reroute();


  function reroute() {
    // parse search string
    var search_string = location.search.substring(1),
        params = $.deparam(search_string);
        filter = params.filter || {};

    // copy values into the declared facets
    context.update_refinements(filter);

    // allow client to update any fields it uses
    if (update_state_fn)
      update_state_fn(params);

    // inform views of state change
    context.trigger('changed', { rerouting : true });
  }
}


// Urls plugin

$.fn.urls = function(update_state_fn, options) {
  return this.each(function() {
    // add locator css class to element, and store faceting context data model in it
    var $elem = $(this);
    var context = $elem.data('context');
    repertoire.urls(context, update_state_fn, $.extend({}, repertoire.defaults, options));
  });
};