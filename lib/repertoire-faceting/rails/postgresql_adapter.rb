require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord #:nodoc: all
  module ConnectionAdapters
    class PostgreSQLColumn
      include Repertoire::Faceting::PostgreSQLColumn
    end
    
    class PostgreSQLAdapter
      include Repertoire::Faceting::PostgreSQLAdapter
    end
  end
end