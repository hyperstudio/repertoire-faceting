###  Installing Repertoire Faceting

N.B.  Repertoire Faceting requires Postgres 9.3+, Rails 3.2+, Ruby 2.0.0+, and JQuery 1.3.2+.

#### Short version.

You need a working Rails app, with a model, controller, and a partial to show the model

1. in Gemfile
`gem 'repertoire-faceting'`

2. install native bitset extensions
`$ bundle install`
`$ rake db:faceting:extensions:install` # (provide sudo your password)

3. in `./app/models/some_model.rb`

```ruby
      class SomeModel
        include Repertoire::Faceting::Model
        facet :some_column
      end
```

5. in `./app/controllers/some_controller`

```ruby
        class SomeController
          include Repertoire::Faceting::Controller
          def base; return SomeModel; end
        end
```

6. in `./config/routes.rb`

```ruby
      SomeApp::Application.routes.draw do
        faceting_for :some_model
      end
```

7. in `./app/assets/javascripts/application.js`

```js
    //= require rep.faceting
```

8. in `./app/assets/stylesheets/application.css`

```css
    /*
    *=...
    *= require rep.faceting
    *=...
```*/
```
in `./app/views/some_controller/index.html.erb`

```html
    <script language="javascript">
      $().ready(function() {
        $('#paintings').facet_context();
        $('.facet').facet();
        $('#results').results();
      });
    </script>
    <div id='paintings'>
      <div id='genre' class='facet'></div>
      <div id='results'></div>
    </div>
```

__That's a complete faceted browser in only 14 new lines of code in your app!__

Additionally, you may wish to index the facets.  At the console or in a migration:

```ruby
    SomeModel.index_facets([:some_column])
```

The faceting subsystem automatically detects available facet indices and uses them when appropriate.


#### Detailed version.

Start with a working Rails application with a PostgreSQL database.

> Note that the canonical resource for using Repertoire Faceting is the
> Repertoire Faceting Example application.  If you have questions, you are
> best served by getting it running and exploring further there. **


* Require repertoire-faceting in Gemfile.

  `gem 'repertoire-faceting'`

* At the command line, bundle everything into your application:

  `$ bundle install`

* From your application root, build and install the repertoire-faceting native
  extensions to PostgreSQL.  These provide a bitwise signature type used to
  index and count facets.

  `$ rake db:faceting:extensions:install     { sudo will prompt you for your password }`

* Load the extension into your local application database.  This ensures the
  plpgsql language is installed, and loads (or re-loads) the new bitset signature
  type.

  `$ psql -c "CREATE EXTENSION faceting;" -U<username> <database>`

  Or, if you prefer to use migrations create one with the following contents:

```ruby
    def self.change
      reversible do |dir
        dir.up   { execute('CREATE EXTENSION faceting') }
        dir.down { execute('DROP EXTENSION faceting CASCADE') }
      end
    end
```

Before proceeding, you can confirm the module is installed as follows.

`$ psql -c "SELECT facet.count('101010101'::facet.signature);" -U<username> <database>`

* Install the faceting mixin in your Rails model and declare a facet on an
  existing database column.  (See the README for complete configuration options
  for facets.)

  In `./app/models/painting.rb`

```ruby
    class Painting
      include Repertoire::Faceting::Model
      facet :genre
    end
```

* Test doing facet count and result queries:

```shell
  $ rails c
  > Painting.count(:genre)
  => {"Impressionist"=>2, "Medieval"=>2}
  > Painting.refine(:genre => 'Impressionist')
  => [#<Painting id: 1, title: "Moonlight Shimmers", painter: "Monet", genre: "Impressionist">,
      #<Painting id: 2, title: "Nude Lunch in Garden", painter: "Manet", genre: "Impressionist">]
```

Or, with a base query as well:

```shell
  > Painting.where(["title like ?", 'Moon%']).count(:genre)
  => {"Impressionist"=>1}
```

* Add faceting webservices to your controller and define base() to indicate which model to base queries on

In `./app/controllers/paintings_controller`

```ruby
    class PaintingsController
      include Repertoire::Faceting::Controller

      def base
        search = "%#{params[:search]}%"
        Painting.where(["title like ?", search])
      end
    end
```

* Add faceting routes to your application.

In `./config/routes.rb`

```ruby
    PaintingsApp::Application.routes.draw do
      faceting_for :paintings         # NB must be BEFORE any resources!
      ...
    end
```

  Confirm they load:

  `$ rake routes`

```ruby
    paintings_counts         /paintings/counts/:facet(.:format) {:controller=>"paintings", :action=>"counts"}
    paintings_results        /paintings/results(.:format)       {:controller=>"paintings", :action=>"results"}
```

* Add facet count and result widgets to your HTML page. The facet context div
  collects widgets that affect the same query together. (For complete options,
  see the README )

In `./app/views/paintings/index.html.erb`

```html
      <script language="javascript">
        $().ready(function() {
          $('#paintings').facet_context();
          $('.facet').facet();
          $('#results').results();
        });
        </script>
      <div id='paintings'>
        <div id='genre' class='facet'></div>
        <div id='results'></div>
      </div>
```

If you don't already have one, create a partial for displaying your model in results lists.

In `./app/views/paintings/_painting.html.erb`

```html
    <div class='painting' style='width:235px; margin-bottom:5px; padding:2px; border:dotted 1px;'>
      <div>Title: <%= painting.title %></div>
        <div>Painter: <%= painting.painter %></div>
        <div>Genre: <%= painting.genre %></div>
    </div>
```

[Optional] Add bitset indexes to some facets on your model. The module will automatically use facet indexes when they are available.  Facet indexes scale out of the box to over a million model items, and requires no additional configuration.

  `$ rails generate migration AddFacetIndex`

In `./db/migrate/<your date>add_facet_index.rb`

```ruby
        class AddFacetIndex < ActiveRecord::Migration
          def self.up
            Painting.index_facets([:genre])
          end

          def self.down
            Painting.index_facets
          end
        end
```

[Optional] Periodically update indexes via a crontab task.

In `./lib/tasks/update_facets.rake`

```ruby
  task :reindex => :environment do
      Painting.index_facets                           # NB this updates whatever indexes already exist
  end
```

And then configure crontab to execute 'rake reindex' at appropriate intervals.
