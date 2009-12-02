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

//= require <rep.widgets/widget>

//= require "context"

//= require "../../stylesheets/rep.faceting.css"
//= provide "../../images/**/*"


repertoire.facet_widget = function($widget, options) {
  var self = repertoire.widget($widget, options);

  // find the relevant data model for this facet
  var context = locate_context();

  // install refinement change listener
  context.bind('changed', function() {
    self.refresh();
  });

  //
  // Return this widget's context (query refinement data model)
  //
  self.context = function() {
    return context;
  };

  //
  // Return an identifier for the context, or undefined
  //
  self.context_name = function() {
    return options.context || self.context().name();
  };

  //
  // Capitalize and return a string
  //
  self.capitalize = function(s) {
    return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
  };
  
  //
  // Locate the facet widget's enclosing context element and extract the data model
  //
  function locate_context() {
    // TODO.  should this be in the jquery plugin, so the facet widget constructor can
    //        accept the context/model as an argument, like other widgets?
    var context = $widget.closest('.facet_refinement_context').data('context');
    if (!context) {
      throw "No facet refinement context defined.";
    }
    return context;
  }

  // end of facet_widget factory function
  return self;
};
