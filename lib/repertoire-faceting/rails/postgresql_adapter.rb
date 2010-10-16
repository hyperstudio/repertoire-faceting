require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      include Repertoire::Faceting::AbstractAdapter
      include Repertoire::Faceting::PostgreSQLAdapter
    end
  end
end