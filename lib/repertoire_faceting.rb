# require code that must be loaded before the application
dir = Pathname(__FILE__).dirname.expand_path + 'repertoire_faceting'

require dir + 'adapters' + 'postgres_adapter'
require dir + 'faceting_functions'

require dir + 'is-faceted'

require DataMapper.root / 'lib' / 'dm-core' / 'adapters' / 'postgres_adapter'
gem 'do_postgres', '~>0.10.0'
require 'do_postgres'

module DataMapper
  module Model
    include Repertoire::Faceting::Functions
  end

  class Collection
    include Repertoire::Faceting::Functions
  end
  
  module Adapters
    class PostgresAdapter
      include Repertoire::Faceting::PostgresAdapter
    end
  end
end


# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:repertoire_faceting] = {
  }
  
  Merb::BootLoader.before_app_loads do    
    # Merb::Controller.send(:include, Repertoire::FacetingMixin)
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  # Merb::Plugins.add_rakefiles "repertoire_faceting/merbtasks"
end