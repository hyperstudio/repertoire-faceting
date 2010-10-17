require 'active_support/dependencies'

module Repertoire
  module Faceting

    module Relation
      autoload :SpawnMethods, 'repertoire-faceting/relation/spawn_methods'
      autoload :QueryMethods, 'repertoire-faceting/relation/query_methods'
      autoload :Calculations, 'repertoire-faceting/relation/calculations'
    end
    
    autoload :Model, 'repertoire-faceting/model'
    autoload :Controller, 'repertoire-faceting/controller'
    autoload :Version, 'repertoire-faceting/version'

    autoload :AbstractFacet, 'repertoire-faceting/facets/abstract_facet.rb'
    
    autoload :AbstractAdapter, 'repertoire-faceting/adapters/abstract_adapter'
    autoload :PostgreSQLAdapter, 'repertoire-faceting/adapters/postgresql_adapter'
  end
end

# rails hook-in code

require 'repertoire-faceting/errors'
require 'repertoire-faceting/rails/relation'
require 'repertoire-faceting/rails/routes'
require 'repertoire-faceting/rails/postgresql_adapter'
require 'repertoire-faceting/railtie'

# default facet implementations

require 'repertoire-faceting/facets/basic_facet.rb'
require 'repertoire-faceting/facets/nested_facet.rb'
