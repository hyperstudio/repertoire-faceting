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

//= require ./rep.faceting/context
//= require ./rep.faceting/facet
//= require ./rep.faceting/facet_widget
//= require ./rep.faceting/nested_facet
//= require ./rep.faceting/results