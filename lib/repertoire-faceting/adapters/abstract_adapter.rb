module Repertoire
  module Faceting
    module AbstractAdapter #:nodoc:

      # Returns the name of the facet index table for a given facet and model
      def facet_table_name(model_name, name)
        "facet._#{model_name}_#{name}_facet"
      end

      # Returns a list of the indexed facets on a model in the database (even
      # if no longer declared on the ruby model)
      def indexed_facets(model_name)
        tables.grep(/facet._#{model_name}_(\w+)_facet/) { $1 }
      end

    end
  end
end