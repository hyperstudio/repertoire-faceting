module Repertoire
  module Faceting
    module AbstractAdapter #:nodoc:

      # N.B. In PostgreSQL, these defaults are not used since all facet indices
      #      are stored in a separate PostgreSQL schema. Should we extend to
      #      support other databases, they will come into play.

      # Returns the name of the facet index table for a given facet and model
      def facet_table_name(model_name, name)
        "_#{model_name}_#{name}_index"
      end

      # Returns a list of the indexed facets on a model in the database (even
      # if no longer declared on the ruby model)
      def indexed_facets(model_name)
        tables.grep(/_#{model_name}_(\w+)_index/) { $1 }
      end

    end
  end
end