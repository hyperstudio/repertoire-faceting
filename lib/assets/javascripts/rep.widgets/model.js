/*
* Repertoire abstract ajax model, for use with widget framework
*
* Copyright (c) 2009 MIT Hyperstudio
* Christopher York, 11/2009
*
* Requires jquery 1.3.2+
* Support: Firefox 3+ & Safari 4+.  IE emphatically not supported.
*/

//
// Abstract model for ajax widgets.  This class includes convenience methods for listening to
// events on models, for jquery ajax calls, and for param encoding in Merb's style.
//
// Handles:
//       - change publication and observing
//       - url/query-string construction
//
// Usage. The model provides a facade to your ajax webservice, and may hold state for a widget.
//        In some cases (e.g. working with large server-side datasets), it may be appropriate to
//        cache data in the model and fetch it as needed from the webservice.
//
// Using the ajax param encoders.  These convenience methods help you construct the url and
//        assemble params for an ajax call.  It's not required to use them, although they make life
//        easier.
//
// self.items = function(callback) {
//   var url = self.default_url(['projects', 'results']);
//   self.fetch(params, url, 'html', callback);
// }
//
repertoire.model = function(options) {
  // this object is an abstract class
  var self = {};
  
  // default: no options specified
  options = options || {};
  
  // mixin event handler functionality
  repertoire.events(self);
  
  //
  // Update the data model given the current state
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
    throw "Abstract function: redefine self.update() in your data model."
  };
  
  //
  // Utility method to issue an ajax HTTP GET to fetch data from a webservice
  //
  //   params:   params to send as http query line
  //   url:      url of webservice to access
  //   type:     type of data returned (e.g. 'json', 'html')
  //   callback: function to call with returned data
  //
  self.fetch = function(params, url, type, callback, $elem, async) {
    if (async == null)
      async = true;

    var spinnerClass = options.spinner || 'loading';
    if ($elem)
      $elem.addClass(spinnerClass);

    $.ajax({
      async:    async,
      url:      url,
      data:     self.to_query_string(params),
      type:     'GET',
      dataType: type,
      // content negotiation problems may require:
      /* beforeSend: function(xhr) { xhr.setRequestHeader("Accept", "application/json") } */
      success:  callback,
      error:    function(request, textStatus, errorThrown) {
          if ($elem)
            $elem.html(options.error || 'Could not load');
      },
      complete: function () {
          if ($elem)
            $elem.removeClass(spinnerClass);
      }
    });
  };
  
  //
  // Format a webservice url, preferring options.url if possible
  //
  self.default_url = function(default_parts, ext) {
    var path_prefix = options.path_prefix || '';
    var parts       = default_parts.slice();

    parts.unshift(path_prefix);
    url = options.url || parts.join('/')

    if (ext)
      url += '.' + ext;

    return url;
  }
  
  //
  // Convert a structure of params to a URL query string suitable for use in an HTTP GET request, compliant with Merb's format.
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
        vs.push(self.to_query_string(v, (prefix.length > 0) ? (prefix + '[' + encodeURIComponent(k) + ']') : encodeURIComponent(k)));
      });
      // minor addition to merb: discard empty value lists { e.g. discipline: [] }
      vs = array_filter(vs, function(x) { return (x !== "") && (x != undefined); });
      return vs.join('&');
    } else if (value) {
      return prefix + '=' + encodeURIComponent(value);
    }
  };

  // Apparently IE doesn't support the filter function? -DD via Brett
  var array_filter = function (thisArray, fun) {
    var len = thisArray.length;
    if (typeof fun != "function")
      throw new TypeError();

    var res = new Array();
    var thisp = arguments[1];

    for (var i = 0; i < len; i++) {
      if (i in thisArray) {
        var val = thisArray[i]; // in case fun mutates this
        if (fun.call(thisp, val, i, thisArray))
          res.push(val);
	     }
    }

    return res;
  };

    
  // end of model factory function
  return self;
}