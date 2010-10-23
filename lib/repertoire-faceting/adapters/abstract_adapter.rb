module Repertoire
  module Faceting
    module AbstractAdapter

      # Returns the name of the facet index table for a given facet and model
      def facet_table_name(model_name, name)
        "_#{model_name}_#{name}_facet"
      end

      # Returns a list of the indexed facets on a model (even if no longer declared on
      # the model itself)
      def indexed_facets(model_name)
        tables.grep(/_#{model_name}_(\w+)_facet/) { $1 }
      end

      # For the given model, drops any unused facet indices, updates its packed ids,
      # then recreates indices for the facets with the provided names.  If no names
      # are provided, then the existing facet indices are refreshed.  The silent option
      # returns a block of sql that accomplishes these tasks, but does not execute them.
      def update_indexed_facets(model_class, facet_names=nil, silent=false)
        sql = []

        # drop un-needed facet indices if operating immediately
        unless silent
          indexed_facets = indexed_facets(model_class.table_name)
          indexed_facets.each do |name|
            table = facet_table_name(model_class.table_name, name)
            drop_table(table)
          end
          facet_names ||= indexed_facets
        end

        # update the model packed id
        sql << renumber_table(model_class.table_name, silent)

        # re-create the facet indices
        facet_names.each do |name|
          raise "Unknown facet #{name}" unless model_class.facet?(name)
          
          table = facet_table_name(model_class.table_name, name)
          facet = model_class.facets[name]
          
          sql << recreate_table(table, facet.index.to_sql, silent)
        end
        
        sql.join('; ')
      end

    end
  end
end