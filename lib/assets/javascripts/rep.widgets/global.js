/*
* Repertoire abstract ajax widget
*
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*/

// claim a single global namespace, 'repertoire'
repertoire = {};

// Global defaults inherited by all widgets
//
// Options:
//   path_prefix - prefix to add before all generated urls
//
repertoire.defaults = {
  path_prefix: ''
};

//
// Generates a jquery plugin that attaches a widget instance to each matched element
// and exposes plugin defaults.
//
// N.B. This method is currently only in use in the faceting module, and may be deprecated.
//
// Usage:
//    $.fn.my_widget = repertoire.plugin(my_widget);
//    $.fn.my_widget.defaults = { /* widget option defaults */ };
//
repertoire.plugin = function(self) {
  var fn = function(options) {
    return this.each(function() {
      var settings = $.extend({}, repertoire.defaults, fn.defaults, html_options($(this)), options);
      self($(this), settings).initialize();
    });
  };
  fn.defaults = { };
  return fn;

  // helper: default widget name and title options from dom
  function html_options($elem) {
    return {
      name: $elem.attr('id'),
      title: $elem.attr('title')
    };
  }
};
