
require 'rubygems'
require 'pathname'

gem 'dm-core', '~>0.9.10'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path / 'is-faceted' / 'is' / 'faceted.rb'
require Pathname(__FILE__).dirname.expand_path / 'is-faceted' / 'is' / 'postgres_adapter'

DataMapper::Model.append_extensions DataMapper::Is::Faceted

# Include the plugin in Resource
module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::Faceted
    end # module ClassMethods
  end # module Resource

  module Adapters
    class PostgresAdapter
      include DataMapper::Is::Faceted::PostgresAdapter::SQL
    end
  end
end # module DataMapper