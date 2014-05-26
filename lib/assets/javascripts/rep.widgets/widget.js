/*
* Repertoire abstract ajax widget
*
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*/

//
// Abstract class for ajax widgets
//
// Handles:
//       - url/query-string construction
//       - data assembly for sending to webservice
//       - ui event delegation hooks
//       - hooks for injecting custom behaviour
//
// Options on all subclassed widgets:
//
//   url         - provide a url to over-ride the widget's default
//   spinner     - css class to add to widget during ajax loads
//   error       - text to display if ajax load fails
//   injectors   - additional jquery markup to inject into widget (see FAQ)
//   handlers    - additional jquery event handlers to add to widget (see FAQ)
//   state  - additional pre-processing for params sent to webservice (see FAQ)
//
// Sub-classes are required to over-ride one method: self.render().  If you wish to
// use a data model, store a subclass of rep.wigets/model in your widget.
//
repertoire.widget = function(selector, options) {
  // this object is an abstract class
  var self    = {};
  
  // private variables
  var $widget = $(selector);
  options     = options || {};
  
  // mix in event handling functionality
  repertoire.events(self, $widget);

  // to run by hand after sub-classes have evaluated
  self.initialize = function() {
    // register any custom handlers
    if (options.handlers !== undefined)
      register_handlers(options.handlers);

    // load once at beginning
    self.refresh();
  }

  //
  // Refresh model and render into widget
  //
  // Integrates state and markup injectors
  //
  // TODO. ajaxStamp and callbackStamp are used to accept only the most
  //       recent ajax sync for this widget.  Better solution would be to wait
  //       until document.ready() has finished before initializing and refreshing
  //       any widgets; or use xhr.abort().
  //
  var ajaxStamp;
  self.refresh = function() {
    var callback,
        callbackStamp;
    
    // pass to custom state processor
    if (options.state !== undefined)
      options.state(self);

    // adjust timestamp to most recent ajax call
    ajaxStamp = callbackStamp = Date.now();
      
    callback = function() {
      // reject if this is an old ajax request
      if (callbackStamp < ajaxStamp) return;

      // render the widget
      var markup = self.render.apply(self, arguments);
      
      // inject any custom markup
      if (options.injectors !== undefined)
        // TODO.  figure out how to send all args to injectors
        process_injectors(markup, options.injectors, arguments[0]);

      // paint markup into the dom
      if (markup)
        $widget.html(markup);
    };

    // start rendering
    self.reload(callback);
  };

  //
  // Render and return markup for this widget.
  //
  // Three forms are possible:
  //
  // (1) Basic... just return a string or jquery object
  //
  //     self.render = function() {
  //       return 'Hello world!';
  //     };
  //
  // (2) If you just want to tweak the superclass' view:
  // 
  //     var template_fn = self.render;            // idiom to access super.render()
  //     self.render = function() {
  //       var markup = template_fn();
  //       return $(markup).find('.title').html('New Title');
  //     };
  //
  // (3) If you want to modify the DOM in place, do so
  //     and return nothing.
  //
  self.render = function() {
    return $('<div class="rep"/>');      // namespace for all other widget css is 'rep'
  };
  
  
  //
  // A hook for use when your widget must render the results of an ajax callback.  Put
  // the ajax call in self.reload().  Its results will be passed to self.render().
  //
  // self.reload = function(callback) {
  //   $.get('http://www.nytimes.com', callback);
  // };
  //
  // self.render = function(daily_news) {
  //   $(daily_news).find('title').text();   // widget's view is the title of the new york times
  // }
  //
  // N.B. In real-world cases, the call in self.reload should be to your
  //      data model class, which serves as an ajax api facade.
  //
  self.reload = function(callback) {
    callback();
  }

  //
  // Register a handler for dom events on this widget.  Call with an event selector and a standard jquery event
  // handler function, e.g.
  //
  //    self.handler('click.toggle_value!.rep .facet .value', function() { ... });
  //
  // Note the syntax used to identify a handler's event, namespace, and the jquery selector: '<event.namespace>!<target>'.
  // Both event and namespace are optional - leave them out to register a click handler with a unique namespace.
  //
  // N.B. This method is intended only for protected use within a widget and its subclasses, since it depends
  //      on the view implementation.
  //
  self.handler = function(event_selector, fn) {
    event_selector = parse_event_selector(event_selector);
    var event    = event_selector[0],
        selector = event_selector[1];  // why doesn't JS support array decomposition?!?
      
    // bind new handler
    $widget.bind(event, function (e) {
      var $el = $(e.target);
      var result = false;
      // walk up dom tree for selector
      while ($el.length > 0) {
        if ($el.is(selector)) {
          result = fn.apply($el[0], [e]);
          if (result === false)
            e.preventDefault();
          return;
        }
        $el = $el.parent();
      }
    });
  }
  
  // PRIVATE
  
  // register a collection of event handlers
  function register_handlers(handlers) {
    $.each(handlers, function(selector, handler) {
      // register each handler
      self.handler(selector, function() {
        // bind self as an argument for the custom handler
        return handler.apply(this, [self]);
      });
    });
  }

  // inject custom markup into widget
  function process_injectors($markup, injectors, data) {
    // workaround for jquery find not matching top element
    $wrapped = $("<div/>").append($markup);

    $.each(injectors, function(selector, injector) {
      var $elems = $wrapped.find(selector);
      if ($elems.length > 0) {
        injector.apply($elems, [ self, data ]);
      }
    });
  }
  
  // parse an event name and selector spec
  function parse_event_selector(event_selector) {
    var s = event_selector.split('!');
    var event, selector;

    if (s.length === 2) {
      event = s[0], selector = s[1];
    } else if (s.length === 1) {
      event = 'click', selector = s[0];
    } else {
      throw "Could not parse event selector: " + event_selector;
    }

    if (event.indexOf('.')<0) {
      // create a default namespace from selector or random number
      namespace = selector.replace(/[^a-zA-z0-9]/g, '') || new Date().getTime();
      event = event + '.' + namespace;
    }

    return [event, selector];
  }

  // end of widget factory function
  return self;
};