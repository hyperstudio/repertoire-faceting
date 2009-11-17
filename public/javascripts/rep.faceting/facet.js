/*
* Repertoire faceting ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
* The default facet value count widget, can be used for either single- or multivalued facets
*
* Usage:
*    
*     $('#discipline').facet(<options>)
*
* Options:
*
*     As for core faceting widget, plus
*     - facet: name of this facet (otherwise defaults to element's id)
*     - title: title to display at top of widget (defaults to element's title)
*     None are required.
*/

//= require "facet_widget"


repertoire.facet = function($facet, options) {
  // this widget inherits from faceting_widget
  var self = repertoire.facet_widget($facet, options);
  // default title
  if (!options.title)
    options.title = self.capitalize(options.name);

  //
  // toggle facet value selection after a user click
  //
  self.handler('click.toggle_value!.rep .facet .value', function() {
    // extract facet value that was clicked
    var value = $(this).data('facet_value');
    if (!value) throw "Value element does not have facet data";
    // determine current refinements for this facet
    var filter = self.refinements(self.facet_name());
    // toggle the facet value's selection
    self.toggle(filter, value);
    // reload entire context
    self.state_changed();
    // do not bubble event
    return false;
  });
    
  //
  // Update facet value counts from webservice
  //
  // By default, the url is '/<context>/counts/<facet>'
  //
  self.update = function(state, callback) {
    // default url is '<context>/results'
    var url = self.default_url([self.context_name(), 'counts', self.facet_name()]);
    // package up the faceting state and send back to results rendering service
    self.fetch(state, url, 'json', callback);
  };

  //
  // Inject facet value markup into template
  //
  var $template_fn = self.render;
  self.render = function(counts) {
    var selected = self.refinements(self.facet_name());
    
    // facet container
    var $value_list = $('<div class="facet"></div>');
    
    // title bar
    $value_list.append( '<div class="title">' + options.title + '<span class="controls"></span><span class="spinner"></span></div>' );
    
    // facet values
    var $values = $('<div class="values"/>')
    $.each(counts, function() {
      var value    = this[0];
      var count    = this[1];
      var sel      = self.is_selected(selected, value);
      var $elem    = $value_count_markup(value, count, sel);
      $elem.data('facet_value', value);
      $values.append($elem);
    });
    
    // opacity mask (for loading)
    $values.append('<div class="mask"/>')
    
    $value_list.append($values);
    return $template_fn(counts).append($value_list);
  };

  // helper: format a single value count
  function $value_count_markup(value, count, selected) {
    var label = value || '...';
    return $('<div class="' + (selected ? 'value selected' : 'value') + '">' +
             '<div class="count">' + count + '</div>' + 
             '<div class="label">' + label + '</div></div>');
  };
  
  //
  // Convenience method to access facet name
  //
  self.facet_name = function() {
    return options.name;
  }
    
  // end of faceting widget factory method
  return self;
};

// Facet plugin
$.fn.facet = repertoire.plugin(repertoire.facet);
$.fn.facet.defaults = { 
  /* no default options yet */ 
};


