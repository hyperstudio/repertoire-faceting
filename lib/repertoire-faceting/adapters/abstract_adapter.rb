module Repertoire
  module Faceting
    module AbstractAdapter

      # Low-level helpers for facet indices

      def facet_table_name(model_name, name)
        "_#{model_name}_#{name}_facet"
      end

      def indexed_facets(model_name)
        tables.grep(/_#{model_name}_(\w+)_facet/) { $1 }
      end

      # High-level migration helpers

      def update_indexed_facets(model_class, facet_names=nil)
        indexed_facets = indexed_facets(model_class.table_name)

        # drop un-needed facet indices
        indexed_facets.each do |name|
          table = facet_table_name(model_class.table_name, name)
          drop_table(table)
        end

        # update the model packed id
        renumber_table(model_class.table_name)

        # re-create the facet indices
        (facet_names || indexed_facets).each do |name|
          raise "Unknown facet #{name}" unless model_class.facet?(name)
          
          table = facet_table_name(model_class.table_name, name)
          facet = model_class.facets[name]
          
          recreate_table(table, facet.index.to_sql)
        end
      end

    end
  end
end