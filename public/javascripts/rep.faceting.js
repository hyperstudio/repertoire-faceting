/*
* Repertoire faceting ajax widgets
* 
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 09/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*
* The package provides 4 jquery plugins:
*   $elem.facet_context() : used to group facets that share state together and extract page state to send to the web service
*   $elem.results() :       display results from the current context facet query
*   $elem.facet() :         display an extensible facet value and count refining widget
*   $elem.nesting_facet():  display and refine on nested facet values
*
* You can configure an existing facet widget using its supported configuration options; or by adding a small handler that inserts
* your own control and event hook into the widget; by subclassing an existing widget to alter its functionality; or by writing
* an entirely new widget based on the core functionality.  It is relatively easy to create widgets that use visualization toolkits
* like Protovis or Processing.js for rendering.
*
* Facet widgets are always collected together in groups that share the same query context (range of potential items and current
* facet refinements).  In practice, the context is simply an enclosing div and facet widgets are contained elements.
*
* Basic example, using faceting widgets out of the box (urls are calculated by default using element ids, or can be set explicitly).
*
*   [ faceting over all plays, with two facets defined (genre and era) ]
*
* $().ready(function() { 
*   $('#plays').facet_context();
*   $('.facet').facet();
*   $('#results').results();
* });
* ...
* <div id='plays'>
*    <div id='genre' class='facet'></div>
*    <div id='play' class='facet'></div>
*    <div id='results'></div>
* </div>
*
* See the README and FAQ for more information.
*
* TODO. can the css for this module be namespaced?
*/

// claim a single global namespace, 'repertoire'
repertoire = {};

(function($) {
  
  //
  // Register an element as the faceting context,
  //   and provide user data extraction function
  //
  // Handles:
  //       - grouping faceting widgets into shared context
  //       - hooks for managing custom data
  // 
  $.fn.facet_context = function(state_fn) {
    return this.each(function() {
      $context_elem = $(this);
      $context_elem.addClass('facet_refinement_context');
      $context_elem.data('facet_state_fn', state_fn);
    });
  };
  
  //
  // Generates a jquery plugin that attaches a widget instance to each matched element
  // and exposes plugin defaults.
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
    
    // helper: default facet name and title options from dom
    function html_options($elem) {
      return {
        name: $elem.attr('id'),
        title: $elem.attr('title')
      };
    }
  };
  
  // Global defaults inherited by all widgets
  //
  // Options:
  //   path_prefix - prefix to add before all generated urls
  //
  repertoire.defaults = {
    path_prefix: ''
  };
  
  //
  // Abstract class for faceting widgets
  //
  // Handles:
  //       - access to faceting context
  //       - manipulation of faceting refinements
  //       - url/query-string construction
  //       - data assembly for sending to webservice
  //       - change publication and observing
  //       - ui event delegation hooks
  //       - hooks for injecting custom behaviour
  //       - system defaults for faceting behaviour
  //       - some text format methods
  //
  // Options on all subclassed widgets:
  //
  //   url         - provide a url to over-ride the widget's default
  //   context     - name of faceting context (otherwise defaults to context element's id)
  //   spinner     - css class to add to widget during ajax loads
  //   error       - text to display if ajax load fails
  //   injectors   - additional jquery markup to inject into widget (see FAQ)
  //   handlers    - additional jquery event handlers to add to widget (see FAQ)
  //   pre_update  - additional pre-processing for params sent to webservice (see FAQ)
  //
  // Sub-classes are required to over-ride two methods: self.update() and self.render().
  // See the documentation for these methods for more details.
  //
  repertoire.facet_widget = function($widget, options) {
    // this object is an abstract class
    var self = {};
    
    // compute context for this facet
    var $context = $widget.closest('.facet_refinement_context');
    
    // install refinement change listener     
    $context.bind('facet_refinement_change', function() {
      self.reload();
    });
    
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
    
    // to run by hand after sub-classes have evaluated
    self.initialize = function() {
      // register any custom handlers
      if (options.handlers !== undefined)
        register_handlers(options.handlers);
      // load once at start up
      self.reload();
    }
    
    // combine context state and any custom user additions
    function customized_state() {
      var state         = self.state();
      var user_state_fn = self.context().data('facet_state_fn');
      return $.extend({}, state, user_state_fn());
    }
    
    // inject custom markup into widget
    function process_injectors($markup, injectors, data) {
      // workaround for jquery find not matching top element
      $wrapped = $("<div/>").append($markup);

      $.each(injectors, function(selector, injector) {
        var $elems = $wrapped.find(selector);
        if ($elems.length > 0)
          injector.apply($elems, [self, data]);
      });
    }
    
    //
    // Reload data from webservice and render into widget
    //
    // Integrates custom context/facet state and markup
    // injectors
    //
    self.reload = function() {
      // retrieve all facets' state + user customizations
      var state = customized_state();
      
      // pass to custom state processor
      if (options.pre_update !== undefined)
        options.pre_update(state);
      
      // fetch data from webservice, render and update DOM
      self.update(state, function(data) {
        var $markup = self.render(data);
        
        // inject any custom markup
        if (options.injectors !== undefined)
          process_injectors($markup, options.injectors, data);
        
        // paint markup into the dom
        $widget.html($markup);
      });
    };
    
    //
    // Update the widget's data given the current faceting state
    //
    // You may either pre-process the state and write your own webservice access methods
    // or use self.fetch for a generic webservice, e.g.
    //
    // self.update = function(state, callback) {
    //   var url = self.default_url(['projects', 'results']);
    //   self.fetch(state, url, 'html', callback);
    // }
    //
    self.update = function(state, callback) {
      throw "Abstract function: redefine self.update() in your widget."
    }
    
    //
    // Inject widget-specific markup into default markup from superclass
    //
    // Over-ride this method to call the superclass markup method and then
    // inject your own widget's markup into it, e.g.
    //
    //   ...
    //   var $template_fn = self.render;            // idiom to access super.render()
    //   self.render = function(data) {
    //     $markup = $template_fn(data);            // get template from superclass
    //     return $markup.append('Hello world!');   // inject this widget's markup into it
    //   }
    //
    self.render = function(data) {
      return $('<div class="rep"/>');               // namespace for all other faceting css is 'rep'
    };
    
    //
    // Utility method to issue an ajax HTTP GET to fetch data from a webservice
    //
    //   state:    params to send as http query line
    //   url:      url of webservice to access
    //   type:     type of data returned (e.g. 'json', 'html')
    //   callback: function to call with returned data
    //
    self.fetch = function(state, url, type, callback) {
      var spinnerClass = options.spinner || 'loading';
      $widget.addClass(spinnerClass);
      $.ajax({
        url: url,
        data: self.to_query_string(state),
        type: 'GET',
        dataType: type,
        // content negoation problems may require:
        /* beforeSend: function(xhr) { xhr.setRequestHeader("Accept", "application/json") } */
        success: callback,
        error:   function() {
          $widget.html(options.error || 'Could not load');
        },
        complete: function () {
          $widget.removeClass(spinnerClass);
        }
      });
    };
    
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
    // Return the state for the entire faceting context (group of widgets)
    //
    self.state = function() {
      var $context = self.context();
      var state = $context.data('facet_refinement_state');
      
      // default to empty object
      if (!state) {
        state = {};
        $context.data('facet_refinement_state', state);
      }
      return state;
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
      var state = self.state();

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
    // Format a webservice url, preferring options.url if possible
    //
    self.default_url = function(default_parts) {
      var path_prefix = options.path_prefix || '';
      var parts = default_parts.slice();
      
      parts.unshift(path_prefix);
      return options.url || parts.join('/');
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
    
    //
    // Register a handler for dom events on this widget.  Call with an event selector and a standard jquery event
    // handler function, e.g.
    //
    //    self.handler('click.toggle_value!.rep .facet .value', function() { ... });
    //
    // Note the syntax used to identify a handler's event, namespace, and the jquery selector: '<event.namespace>!<target>'.
    // Both event and namespace are optional - leave them out to register a click handler with a unique namespace.
    //
    // To replace an existing handler, register another with the same event name, namespace, and target.  To enable later users
    // to do this, it's best to namespace all your events.
    //
    self.handler = function(event_selector, fn) {
      event_selector = parse_event_selector(event_selector);
      var event    = event_selector[0], 
          selector = event_selector[1];  // why doesn't JS support array decomposition?!?
      
      // provide opportunity to replace existing handlers
      $widget.unbind(event);
      // bind new handler
      $widget.bind(event, function (e) {
        var el = $(e.target);
        var result = false;
        // walk up dom tree for selector
        while (!$(el).is('body')) {
          if ($(el).is(selector)) {
            result = fn.apply($(el)[0], [e]);
            if (result === false)
              e.preventDefault();
            return;
          } 
          el = $(el).parent();
        }
      });
    }
    
  
    // end of facet_widget factory function
    return self;
  };
  
  
  //
  // A barebones faceting results widget.  HTML rendering is done on the server side.
  //
  // Usage:
  //
  //   $('#my_results').results(<options>)
  //
  // Options:  As for basic faceting widgets
  //           - type:  return type for ajax query
  //           None are required.
  //
  repertoire.results = function($results, options) {
    // inherit basic facet widget behaviour
    var self = repertoire.facet_widget($results, options);
    
    //
    // Update results from webservice
    //
    // By default, the url is '/<context>/counts/<facet>'
    //
    self.update = function(state, callback) {
      // default url is '<context>/results'
      var url = self.default_url([self.context_name(), 'results']);
      // package up the faceting state and send back to results rendering service
      self.fetch(state, url, options.type, callback);
    }
    
    //
    // Render only fetched html
    //
    var $template_fn = self.render;
    self.render = function(data) {
      var $markup = $template_fn();
      
      // if html returned, use it; otherwise defer to a custom injector
      if (options.type == 'html')
        $markup.append(data);
        
      // opacity mask (for loading)
      $markup.append('<div class="mask"/>')

      return $markup;
    }
    
    // end of results factory function
    return self;
  };
  
  // Results plugin
  $.fn.results = repertoire.plugin(repertoire.results);
  $.fn.results.defaults = {
    type: 'html'          /* jquery ajax type: html, json, xml */
  };
  
  
  //
  // The default facet value count widget, can be used for either single- or multivalued facets
  //
  // Usage:
  //    
  //     $('#discipline').facet(<options>)
  //
  // Options:
  //
  //     As for core faceting widget, plus
  //     - facet: name of this facet (otherwise defaults to element's id)
  //     - title: title to display at top of widget (defaults to element's title)
  //     None are required.
  //
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
  
  
  //
  // Nested facet value widget
  //
  // Usage:
  //    
  //     $('#birthplace').nested_facet(<options>)
  //
  // Options:
  //
  //     As for default facet widget, plus
  //     - delim: delimiter between nesting levels
  //     None are required.
  //
  repertoire.nested_facet = function($facet, options) {
    // inherit complete facet-value-count widget behaviour
    var self = repertoire.facet($facet, options);
    
    self.handler('click!.rep .facet .nesting_level', function() {
      // extract the nesting level to clear beyond
      var level = $(this).data('facet_nesting_level');
      if (level === undefined) throw "Nesting context element does not have level data";
      // get current refinements for this facet
      var filter = self.refinements(self.facet_name());
      // clear all beyond clicked level and update entire context
      filter.splice(level);
      self.state_changed();
      return false;
    });
    
    //
    // Inject nesting level markup into template for facet value count widget
    //
    var $template_fn = self.render;
    self.render = function(counts) {
      var $markup = $template_fn(counts);
      var selected = self.refinements(self.facet_name());
      
      // deselect any values chosen by the default renderer; 
      // nested selections are in line above values
      $markup.find('.selected').removeClass('selected');
      
      // format nesting summary
      var $nesting = $('<div class="nesting"></div>');
      
      // collect element for each level
      var $elems   = $.map(selected, function(v, i) {
        var $elem  = $('<span class="nesting_level selected">' + v + '</span>');
        $elem.data('facet_nesting_level', i);
        return $elem;
      });

      // inject into summary interspersed with delimiter
      $.each($elems, function(i, e) {
        $nesting.append(e);
        if (i < $elems.length-1)
          $nesting.append(options.delim);
      });
      
      // inject the nesting summary directly before the facet values list
      $markup.find('.values').before($nesting);
      
      return $markup;
    };

    // end of faceting widget factory method
    return self;
  };
  
  // Nested facet plugin
  $.fn.nested_facet = repertoire.plugin(repertoire.nested_facet);
  $.fn.nested_facet.defaults = {
    delim: '&nbsp;/ '                       /* delimiter between nesting levels */
  };
  
})(jQuery);
