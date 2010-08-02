require "active_record"

# require code that must be loaded before the application
dir = Pathname(__FILE__).dirname.expand_path + 'repertoire_faceting'

require dir + 'adapters' + 'postgres_adapter'
require dir + 'faceting_functions'
require dir + 'facet_query'

require dir + 'is-faceted'

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Repertoire::Faceting::Functions
end


=begin
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
=end