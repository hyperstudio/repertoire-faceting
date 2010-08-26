require 'active_support/dependencies'

module Repertoire
  module Faceting

    autoload :Calculations, 'repertoire_faceting/calculations'
    autoload :Controller, 'repertoire_faceting/controller'
    autoload :Model, 'repertoire_faceting/model'
    autoload :Version, 'repertoire_faceting/version'

    autoload :Railtie, 'repertoire_faceting/railtie'

    #autoload :'repertoire_faceting/adapters/postgres_adapter'

  end
end

require 'repertoire_faceting/rails/relation'
require 'repertoire_faceting/rails/routes'