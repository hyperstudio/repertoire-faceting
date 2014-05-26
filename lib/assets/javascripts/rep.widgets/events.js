/*
* Repertoire abstract event model, for use with widget model
*
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 11/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*/

//
// Mixin that adds functionality for event listening to an arbitrary javascript object.
//
// API is the similar to jquery's bind, unbind, and trigger - except that events cannot be
//     namespaced.
//
// N.B. This is not a true event dispatch system: there is no event object, just callbacks.
//      Implementation may change.
//
repertoire.events = function(self, $proxy) {
  
  var handlers = {};

  // mimic jquery's event bind
  self.bind = function(type, fn) {
    if (!handlers[type])
      handlers[type] = [];
      
    handlers[type].push(fn);
  };
  
  // mimic jquery's event unbind
  self.unbind = function(type, fn) {
    if (handlers[type]) {
      handlers[type] = jQuery.grep(handlers[type], function(h) {
        return h !== fn;
      });
    }
  };

  // wrap jquery's event trigger
  self.trigger = function(type, data) {
    data = data || {};
    if (handlers[type]) {
      jQuery.each(handlers[type], function() {
        this.call(self, data);
      })
    }
  };
  
  return self;
};