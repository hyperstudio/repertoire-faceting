puts "LOADING FACETING FILES"


require 'active_support/dependencies'

module Repertoire
  module Faceting

    autoload :Calculations, 'repertoire-faceting/calculations'
    autoload :Controller, 'repertoire-faceting/controller'
    autoload :Model, 'repertoire-faceting/model'
    autoload :Version, 'repertoire-faceting/version'

    autoload :Railtie, 'repertoire-faceting/railtie'

    #autoload :'repertoire-faceting/adapters/postgres_adapter'

  end
end

require 'repertoire-faceting/rails/relation'
require 'repertoire-faceting/rails/routes'