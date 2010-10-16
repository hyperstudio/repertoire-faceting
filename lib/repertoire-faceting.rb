require 'active_support/dependencies'

module Repertoire
  module Faceting

    module Relation
      autoload :SpawnMethods, 'repertoire-faceting/relation/spawn_methods'
      autoload :QueryMethods, 'repertoire-faceting/relation/query_methods'
      autoload :Calculations, 'repertoire-faceting/relation/calculations'
      autoload :Signatures, 'repertoire-faceting/relation/signatures'
    end
    
    autoload :Model, 'repertoire-faceting/model'
    autoload :Controller, 'repertoire-faceting/controller'
    autoload :Expressions, 'repertoire-faceting/expressions'
    autoload :Version, 'repertoire-faceting/version'
    
    autoload :AbstractAdapter, 'repertoire-faceting/adapters/abstract_adapter'
    autoload :PostgreSQLAdapter, 'repertoire-faceting/adapters/postgresql_adapter'

  end
end

require 'repertoire-faceting/errors'
require 'repertoire-faceting/rails/relation'
require 'repertoire-faceting/rails/routes'
require 'repertoire-faceting/rails/postgresql_adapter'
require 'repertoire-faceting/railtie'