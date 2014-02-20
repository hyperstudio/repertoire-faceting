require 'active_support/dependencies'

module Repertoire
  module Faceting
    
    MODULE_PATH = File.expand_path('../../', __FILE__)
    
    module Relation
      autoload :SpawnMethods, 'repertoire-faceting/relation/spawn_methods'
      autoload :QueryMethods, 'repertoire-faceting/relation/query_methods'
      autoload :Calculations, 'repertoire-faceting/relation/calculations'
    end
    
    module Facets
      autoload :AbstractFacet, 'repertoire-faceting/facets/abstract_facet.rb'
    end

    autoload :Model, 'repertoire-faceting/model'
    autoload :Controller, 'repertoire-faceting/controller'
    autoload :Routing, 'repertoire-faceting/routing'
    autoload :Version, 'repertoire-faceting/version'
    
    autoload :AbstractAdapter, 'repertoire-faceting/adapters/abstract_adapter'
    autoload :PostgreSQLColumn, 'repertoire-faceting/adapters/postgresql_adapter'
    autoload :PostgreSQLAdapter, 'repertoire-faceting/adapters/postgresql_adapter'
  end
end

# rails hook-in code

require 'repertoire-faceting/errors'
require 'repertoire-faceting/rails/engine'
require 'repertoire-faceting/rails/relation'
require 'repertoire-faceting/rails/routes'
require 'repertoire-faceting/rails/postgresql_adapter'
require 'repertoire-faceting/railtie'

# default facet implementations

require 'repertoire-faceting/facets/basic_facet.rb'
require 'repertoire-faceting/facets/nested_facet.rb'
