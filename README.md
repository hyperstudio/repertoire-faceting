###  Repertoire Faceting README

Repertoire Faceting is highly scalable and extensible module for creating database-driven faceted browsers in Rails 3 & 4. It consists of three components: (1) a native PostgreSQL data type for constructing fast bitset indices over controlled vocabularies; (2) Rails model and controller mixins that add a faceting API to your existing application; and (3) a set of extensible javascript widgets for building user-interfaces. In only 10-15 lines of new code you can implement a fully-functional faceted browser for your existing Rails data models, with scalability out of the box to over 1,000,000 items.

####  Features

Several features distinguish Repertoire Faceting from other faceting systems such as Simile Exhibit, Endeca, and Solr.

Repertoire Faceting is an end-to-end solution that works with your existing database schema and Rails models. There's no need to munge your data into a proprietary format, run a separate facet index server, or construct your own user-interface widgets. (Conversely, however, your project needs to use Rails, PostgreSQL, and JQuery.)

The module works equally well on small and large data sets, which means there's a low barrier to entry but existing projects can grow easily. In 'training wheels' mode, the module produces SQL queries for facet counts directly from declarations in your model so you can get a project up and running quickly. Then, after your dataset grows beyond a thousand items or so, just add indices as necessary. The module detects and uses these automatically, with no changes to your code or additional SQL necessary.

Unlike some faceting systems, hierarchical vocabularies are supported out of the box. Using familiar SQL expressions you can decompose a date field into a drillable year / month / day facet. Or you can combine several columns into a single nested facet, for example from countries to states to cities.

Both facet widgets and indexes are pluggable and extensible. You can subclass the javascript widgets to build drillable data visualizations, for example using bar graphs, donut and scatter charts or heat-maps to display the current search state and results.

Similarly, you can write new facet implementations for novel data types, which automatically detect and index appropriate columns. For example, the module has been used to do facet value counts over GIS data points on a map, by drilling down through associated GIS layers using spatial logic relations.

For an out-of-the box example using Repertoire Faceting, which demonstrates the module's visualization and scalability features, see the example application (http://github.com/christopheryork/repertoire-faceting-example).


####  Installation

See the INSTALL document for a description of how to install the module and build a basic faceted browser for your existing Rails app.


####  Running unit tests

You can run the unit tests from the module's root directory. You will need a local PostgreSQL superuser role with your unix username (use 'createuser -Upostgres').

  `$ bundle install`
  `$ rake db:setup`
  `$ rake test`


####  Generating documentation

All API documentation, both ruby or javascript, is inline.  To generate:

  `$ rake doc`

For the javascript API documentation, please look in the source files.


####  Faceting declarations (Model API)

See Repertoire::Faceting::Model::ClassMethods


####  Faceting webservices (Controller API)

See Repertoire::Faceting::Controller


####  Facet widgets / HTML (User Interface API)

See rep.faceting.js inline documentation in the source tree


####  Custom facet implementations

See Repertoire::Faceting::Facets::AbstractFacet


####  Updating Facet Indices

It is very useful to create a rake task to update your application's indices. In the project's rake task file:

```ruby
  task :reindex => :environment do
    Painting.index_facets([:genre, :era])
  end
```

Then run 'rake reindex' whenever you need to update indices manually.

*static* If the facet data is unchanging, use a rake task like the one above to create indices manually while developing or deploying.

*crontab* The easiest way to update indices periodically is to run a rake task like the one above via a UNIX tool such as launchd, periodic, or crontab. See the documentation for your tool of choice.


####  Deployment

Because repertoire-faceting depends on a native shared library loaded by the PostgreSQL server, the first time you deploy you will need to build and install the extension.

```shell
  $ bundle install --deployment
  $ export RAILS_ENV=production
  $ rake db:faceting:extensions:install
```
...from here, follow normal deployment procedure

####  How the module works

It is helpful to think of faceted data as a set of model items categorised by one or more controlled vocabularies, as this eliminates confusion from the start. (A faceted classification is neither object-oriented nor relational, though it can be represented in either.) For example, one might categorise Shakespeare's plays by a controlled vocabulary of genres -- comedy, history, tragedy, or romance. Counting the total number of plays for each vocabulary item in this "genre" facet, we see 13 comedies, 10 histories, 10 tragedies, and 4 romances.

There are three direct implementations for faceted classifications like this in an SQL database. The controlled vocabulary can be listed explicitly in a separate table, or implicit in the range of values in a column on the central table (for single-valued facets) or on a join table (for multi-valued facets). Repertoire Faceting supports all of these configurations.

1. Explicit controlled vocabulary, multiple valued facet

```sql
    genres            plays_genres            plays
  ----+---------    ---------+----------    ----+------------------+---------
   id | name         play_id | genre_id      id | title            | date ...
  ----+---------    ---------+----------    ----+------------------|---------
    1 | comedy             1 | 4              1 | The Tempest      |
    2 | tragedy            2 | 3              2 | Henry 4, pt 1    |
    3 | history            3 | 3              3 | Henry 4, pt 2    |
    4 | romance            4 | 3              4 | Henry 5          |
                           5 | 1              5 | As You Like It   |
                           6 | 1              6 | Comedy of Errors |
                           7 | 2              7 | Macbeth          |
                           8 | 2              8 | Hamlet           |
                               ...                ....

```

2. Implicit vocabulary, multiple valued facet

```sql
    plays_genres            plays
  ---------+----------    ----+------------------+---------
   play_id | genre_id      id | title            | date ...
  ---------+----------    ----+------------------|---------
         1 | romance        1 | The Tempest      |
         2 | history        2 | Henry 4, pt 1    |
         3 | history        3 | Henry 4, pt 2    |
         4 | history        4 | Henry 5          |
         5 | comedy         5 | As You Like It   |
         6 | comedy         6 | Comedy of Errors |
         7 | tragedy        7 | Macbeth          |
         8 | tragedy        8 | Hamlet           |
             ...                ....
```

3. Implicit vocabulary, single valued facet

```sql
    plays
  ----+-----------------+---------+---------
   id | title           | genre   | date ...
  ----+-----------------|---------+---------
    1 | The Tempest     | romance |
    2 | Henry 4, pt 1   | history |
    3 | Henry 4, pt 2   | history |
    4 | Henry 5         | history |
    5 | As You Like It  | comedy  |
    6 | Comedy of Errors| comedy  |
    7 | Macbeth         | tragedy |
    8 | Hamlet          | tragedy |
       ...                ....
```

For all of these representations, Repertoire Faceting works by constructing an inverted bitset index from the controlled vocabulary to your central model. Each bit represents a distinct model row (plays.id in this example). 1 indicates the play is in the category, and 0 that it is not:

```sql
    _plays_genre_facet
  ---------+-----------
    genre  | signature
  ---------+-----------
   comedy  | 00001100
   history | 01110000
   romance | 10000000
   tragedy | 00000011

```

From these bitset "signatures", Repertoire Faceting can easily count the number of member plays for each category, even in combination with other facets and a base query. For example, the bitset signature for all plays whose title contains the search word "Henry" is 0110000. Masking this (via bitwise "and") with each signature in the genre index above, we see that there are 2 histories that match the base search - Henry 4 parts 1 & 2 - a none in the other categories:

```sql
  ---------+------------------
    genre  | signature & base
  ---------+------------------
   comedy  | 00000000
   history | 01100000
   romance | 00000000
   tragedy | 00000000
```

Refinements on other facets are processed similarly, by looking up the relevant bitset signature for the refined value, and masking it against each potential value in the facet to be enumerated.

As you may have noticed, this scheme depends on play ids being sequential. Otherwise many bits corresponding to no-existent ids are wasted in every signature. To address this issue, Repertoire Faceting examines the projected wastage in constructing bitset signatures from the primary key id of your model table. If more than a predefined amount (e.g. 15%) of the signature would be wasted, the module instead adds a new column of sequentially packed ids that are used only for faceted searches. When the model's facets are re-indexed, the ids are examined and repacked if too much space is wasted.

References on faceted search:

- http://flamenco.berkeley.edu/pubs.html
- http://en.wikipedia.org/wiki/Controlled_vocabulary


####  A Quick Tour of API Levels

The Repertoire Faceting module is intended to be a toolkit for building highly-scaleable faceted browsers over data held in relational databases. While it can be used as a black box (see the INSTALL document for a recipe), each API is also designed to be called directly. For example, you might write your own facet widgets in Javascript, using the JSON data feeds from the web service API level.

The API layers are:

  - Javascript widgets              [ see lib/assets/javascripts
  - JSON web services               [ see Repertoire::Faceting::Controller, Repertoire::Faceting::Routing
  - Rails model & finders           [ see Repertoire::Faceting::Model
  - SQL queries and indexes         [ see ext/README.md

To the relationships between the APIs clear, here is the same basic facet count query traced through each layer. While the module itself does not always issue exactly the queries listed here, the basic data model is the same. (To experiment with the APIs, run psql or the rails console from the Repertoire Faceting Example application. You may wish to use "SET search_path = public, facet" to bring the faceting schema's namespace into scope.)

*** SQL API ***

The most basic facet count query is a simple SQL aggregation.

```sql
  =# SELECT discipline, COUNT(*) FROM nobelists GROUP BY discipline;
         discipline      | count
    ---------------------+-------
     Chemistry           |    12
     Peace               |     2
     Economics           |    13
     Medicine/Physiology |     9
     Physics             |    27
    (5 rows)
```

Here is the facet value index for nobelist.discipline, as described in the prior section of the README.

```sql
    =# SELECT * FROM facet.nobelists_discipline_index;
         discipline      |                            signature
    ---------------------+------------------------------------------------------------------
     Physics             | 01011011001100110100100101000011010100001000001110110100110001
     Chemistry           | 0000010000001100000000000000100000001011000101000100101
     Economics           | 0010000001000000000101001000010010100000001000000000000000111001
     Medicine/Physiology | 000000001000000010100010001100000000000001000000000000010000001
     Peace               | 000000000000000000000000000000000000010000001
    (5 rows)
```

The faceting API's count() function returns the number of set bits in a signature. The same query, using a facet value index:

```sql
    =# SELECT discipline, facet.count(signature) FROM facet.nobelists_discipline_index;
         discipline      | count
    ---------------------+-------
     Physics             |    27
     Chemistry           |    12
     Economics           |    13
     Medicine/Physiology |     9
     Peace               |     2
    (5 rows)
```

One of the cardinal virtues of faceted search is that facet value counts show the "landscape" of data surrounding a base query. For example, here is a raw facet value count using "Robert" and the base query.

```sql
    =# SELECT discipline, COUNT(*) FROM nobelists WHERE name LIKE 'Robert%' GROUP BY discipline;
     discipline | count
    ------------+-------
     Chemistry  |     2
     Physics    |     1
     Economics  |     5
    (3 rows)
```

(* Keep in mind a proper data model would use full-text index here.)

To run facet value counts, we first gather a signature representing the base query, then use it as a mask over each entry in the facet value index. Here is a representative base query in raw SQL:

```sql
    =# SELECT id, name, discipline, _packed_id FROM nobelists WHERE name LIKE 'Robert%';
         id     |         name          | discipline | _packed_id
    ------------+-----------------------+------------+------------
       57839852 | Robert Burns Woodward | Chemistry  |         39
      506489850 | Robert B. Laughlin    | Physics    |         40
      920398821 | Robert M. Solow       | Economics  |         42
       54824727 | Robert S. Mulliken    | Chemistry  |         43
      309696094 | Robert J. Aumann      | Economics  |         58
      249288376 | Robert C. Merton      | Economics  |         59
      889316300 | Robert Engle          | Economics  |         60
     1039451971 | Robert A. Mundell     | Economics  |         63
    (8 rows)
```
We can use the faceting API aggregator to read this result into a signature. (Note we use the serial id column, since the primary key is quite sparse.)

```sql
    =# SELECT facet.signature(_packed_id) FROM nobelists WHERE name LIKE 'Robert%';
                                signature
    ------------------------------------------------------------------
     0000000000000000000000000000000000000001101100000000000000111001
    (1 row)
```

Combining this base mask bitwise with each of the signatures in the facet value indices allows us to quickly calculate counts for very large datasets. (*For clarity we access the faceting namespace directly and use a subquery).

```sql
    =# SET search_path TO public, facet;
    =# SELECT discipline, facet.count(index.signature & base.signature) FROM
          (SELECT facet.signature(_packed_id) FROM nobelists              WHERE name LIKE 'Robert%') AS base,
          facet.nobelists_discipline_index                                                           AS index;


         discipline      | count
    ---------------------+-------
     Physics             |     1
     Chemistry           |     2
     Economics           |     5
     Medicine/Physiology |     0
     Peace               |     0
    (5 rows)
```

If other facet values have been refined, they are also collected into signatures and used as masks.

```sql
    =# SELECT discipline, facet.count(index.signature & base.signature & refine.signature) FROM
          (SELECT facet.signature(_packed_id) FROM nobelists              WHERE name LIKE 'Robert%') AS base,
          (SELECT signature                   FROM nobelists_degree_index WHERE degree = 'Ph.D.')    AS refine,
          facet.nobelists_discipline_index                                                           AS index;
```

In this fashion, facet count queries can be reduced to a single table scan over the model for the base query, plus an index table scan for each facet that has been refined.

Each of the PostgreSQL API bindings implements these same operators, but over a different bitmap value type.

*** ActiveRecord API ***

  [ See Repertoire::Faceting::Model for full details ]

The ActiveRecord API is built around the observation that our basic facet value count query is built-in to Rails:

```ruby
    > Nobelist.count(:discipline)
    => {"Physics"=>27, "Economics"=>13, "Chemistry"=>12, "Medicine/Physiology"=>9, "Peace"=>2}
```

When the Repertoire Faceting module is loaded and facets declared in the model, the same query will read the facet index instead. Execute the query in the console, and you will see the SQL generated reads the facet value index rather than the model table.

```ruby
    > Nobelist.index_facets([:discipline, :degree])
    > Nobelist.count(:discipline)
    => {"Physics"=>27, "Economics"=>13, "Chemistry"=>12, "Medicine/Physiology"=>9, "Peace"=>2}
```

Facets act just like Rails scoped queries, so you can use ActiveRecord's native syntax to specify a base query.

```ruby
    > Nobelist.where("name LIKE 'Robert%'").count(:discipline)
    => {"Economics"=>5, "Chemistry"=>2, "Physics"=>1}
```

Use refine() to specify facet value refinements on other attribtues.

```ruby
    > Nobelist.where("name LIKE 'Robert%'").refine(:degree => 'Ph.D.').count(:discipline)
    => {"Economics"=>3, "Physics"=>1}
```

You will see from the SQL query that the faceting module is detecting which model column to use as an id key, then reading the facet value indices wherever possible. The result is similar to the final SQL API example above.

If you use refine() without count(), the module will use facet value indices to calculate the list of final results.

```ruby
    > Nobelist.where("name LIKE 'Robert%'").refine(:degree => 'Ph.D.')
    => ...
```

Note that because facets are assumed to be multi-valued, refine() is different from a normal ActiveRecord where() clause. In rails an equivalent query would be:

```ruby
    > Nobelist.where("name LIKE 'Robert%'").joins(:affiliations).where('affiliations.degree' => 'Ph.D.')
    => ...
```

When the number of rows in the model table is large and many facets come into play, using refine() can yield a performance gain over the straight query.

*** Web services API ***

The web services API exposes two JSON feeds, one that returns facet value counts given a set of refinements and another that returns the actual list of results. Your Rails controller constructs the base query, and the faceting webservice handles the surrounding facet refinements. For example, one of the faceting example application's controllers declares a query similar to this:

```ruby
  class NobelistsController < ApplicationController
  ...
  def base
    search = "#{params[:search]}%"
    Nobelist.where(["name ILIKE ?", search])
  end
```
After including "faceting_for :nobelists" in the router, you can query the indexer by facet name, base query, and refinement filter:

```shell
    $ curl -g "http://localhost:3000/nobelists/counts/discipline"
    [["Physics",27],["Economics",13],["Chemistry",12],["Medicine/Physiology",9],["Peace",2]]

    $ curl -g "http://localhost:3000/nobelists/counts/discipline?search=Robert"
    [["Economics",5],["Chemistry",2],["Physics",1]]

    $ curl -g "http://localhost:3000/nobelists/counts/discipline?filter[degree][]=Ph.D.&search=Robert"
    [["Economics",3],["Physics",1]]
```

Or you can issue a refinement query to get the results list:

```shell
    $ curl -g "http://localhost:3000/nobelists/?filter[degree][]=Ph.D.&search=Robert"
    => ...
```

####  Appendix. PostgreSQL in-database Faceting API

Several bindings for the in-database faceting API are provided. In order of capability, they are:

- signature        C language, requires superuser permissions
- bytea            Javascript language, requires plv8 extension
- varbit           No language or superuser requirements

In general, if you have superuser permissions you should build and install the C-language (signature) API, as it is more scalable than the others, at no cost.

All the Repertoire Faceting APIs add functionality for bitwise operations and population counts to PostgreSQL. For API details, see the ext directory.

Signature: an auto-sizing bitset with the following functions

- count(a)            => { count of 1s in a }
- contains(a, i)      => { true if the ith bit of a set }
- members(a)          => { set of integers corresponding to set bits }

- sig_in, sig_out     => { mandatory I/O functions }
- sig_and(a, b)    	  => a & b
- sig_or(a, b)     	  => a | b
- sig_length(a)	      => { number of bits in a }
- sig_get(a, i)       => { ith bit of a, or 0 }
- sig_set(a, i, n)    => { sets ith bit of a to n }
- sig_resize(a, n)    => { resizes a to hold at least n bits }

Bitwise signature operators:  &, |

Bitwise aggregates:

- signature(int)      => assemble ints into a signature
- collect(signature)  => 'or' signature results together
- filter(signature)   => 'and' signature results together

Helper aggregates:

- wastage(INT) -> REAL

Aggregator that examines a table's primary key column, checking what proportion of signature bits constructed from the table would be wasted. If the proportion of wasted bits to valid bits is high, you should consider adding a new serial column.

The Rails API introspects signature wastage before any facet indexing operation, and adds or removes a new serial column (called _packed_id) as necessary.
