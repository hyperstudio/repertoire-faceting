module Repertoire
  module Faceting
    module PostgreSQLAdapter

      def facet_table_name(model_name, name)
        "_#{model_name}_#{name}_facet"
      end

      def indexed_facet?(model_name, name)
        table_name = facet_table_name(model_name, name)
        table_exists?(table_name)
      end

    end
  end
end