/*
* Repertoire faceting ajax widgets
*
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
* Abstract class for faceting widgets
*
* Handles:
*       - access to faceting context
*       - manipulation of faceting refinements
*       - url/query-string construction
*       - data assembly for sending to webservice
*       - change publication and observing
*       - ui event delegation hooks
*       - hooks for injecting custom behaviour
*       - system defaults for faceting behaviour
*       - some text format methods
*
* Options on all subclassed widgets:
*
*   url         - provide a url to over-ride the widget's default
*   context     - name of faceting context (otherwise defaults to context element's id)
*   spinner     - css class to add to widget during ajax loads
*   error       - text to display if ajax load fails
*   injectors   - additional jquery markup to inject into widget (see FAQ)
*   handlers    - additional jquery event handlers to add to widget (see FAQ)
*   pre_update  - additional pre-processing for params sent to webservice (see FAQ)
*
* Sub-classes are required to over-ride two methods: self.update() and self.render().
* See the documentation for these methods for more details.
*/

//= require <jquery>
//= require <rep.widget>

//= require "context"

//= require "../../stylesheets/rep.faceting.css"
//= provide "../../images/**/*"


repertoire.facet_widget = function($widget, options) {
  var self = repertoire.widget($widget, options);

  // compute context for this facet
  var $context = $widget.closest('.facet_refinement_context');

  // install refinement change listener
  $context.bind('facet_refinement_change', function() {
    self.reload();
  });

  //
  // Locate and return this widget's refinement context (a dom element)
  //
  self.context = function() {
    if (!$context) {
      throw "No facet refinement context defined.";
    }
    return $context;
  };

  //
  // Return an identifier for the context, or undefined
  //
  self.context_name = function() {
    return options.context || self.context().attr('id');
  };

  //
  // Return the state for the entire faceting context (group of widgets),
  // with any context-specific additions
  //
  self.state = function() {
    var $context = self.context();
    var state = $context.data('facet_refinement_state') || {};
    var user_state_fn = self.context().data('facet_state_fn');

    // add any custom additions
    return $.extend({}, state, user_state_fn());
  };

  //
  // Trigger a 'facet refinements changed' event to reload all widgets in context
  //
  self.state_changed = function() {
    var $context = self.context();
    $context.trigger('facet_refinement_change');
  };

  //
  // Return the current refinements for one facet, or all if no facet given
  //
  // Changes to the returned object are persistent, but you must call self.state_changed()
  // to trigger an update event.
  //
  self.refinements = function(name) {
    var $context = self.context();
    var state = $context.data('facet_refinement_state');

    // default to empty object
    if (!state) {
      state = {};
      $context.data('facet_refinement_state', state);
    }

    // set up refinements for all facets on first access
    if (!state.filter)
      state.filter = {};

    if (!name) {
      // if no facet provided, return all
      return state.filter;
    } else {
      // set up refinements for this facet
      if (!state.filter[name])
        state.filter[name] = [];

      // return current refinements
      return state.filter[name];
    }
  };

  //
  // Return true/false depending if a value is present in the list of values
  //
  self.is_selected = function(values, item) {
    return ($.inArray(item, values) > -1);
  };

  //
  // Toggles whether facet value is selected in the list of values
  //
  self.toggle = function(values, item) {
    var index = $.inArray(item, values);

    if (index == -1)
      values.push(item);
    else
      values.splice(index,1);

    return values;
  };

  //
  // Capitalize and return a string
  //
  self.capitalize = function(s) {
    return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
  };

  //
  // Convert a structure of of params to a URL query string suitable for use in an HTTP GET request, compliant with Merb's format.
  //
  //   An example:
  //
  //   Merb::Parse.params_to_query_string(:filter => {:year => [1593, 1597], :genre => ['Tragedy', 'Comedy'] }, :search => 'William')
  //   ==> "filter[genre][]=Tragedy&filter[genre][]=Comedy&filter[year][]=1593&filter[year][]=1597&search=William"
  //
  self.to_query_string = function(value, prefix) {
    var vs = [];
    prefix = prefix || '';
    if (value instanceof Array) {
      jQuery.each(value, function(i, v) {
        vs.push(self.to_query_string(v, prefix + '[]'));
      });
      return vs.join('&');
    } else if (typeof(value) == "object") {
      jQuery.each(value, function(k, v) {
        vs.push(self.to_query_string(v, (prefix.length > 0) ? (prefix + '[' + escape(k) + ']') : escape(k)));
      });
      // minor addition to merb: discard empty value lists { e.g. discipline: [] }
      vs = vs.filter(function(x) { return x !== ""; });
      return vs.join('&');
    } else {
      return prefix + '=' + escape(value);
    }
  };

  // end of facet_widget factory function
  return self;
};
