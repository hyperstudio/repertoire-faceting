require 'active_support/ordered_hash'

module Repertoire
  module Faceting
    module PostgreSQLAdapter
      
      # Helpers for renumbering and re-creating tables
      
      def renumber_table(table_name)
        sql = "SELECT renumber_table('#{table_name}', '_packed_id')"
        execute(sql)
      end
      
      def recreate_table(table_name, sql)
        sql = "SELECT recreate_table('#{table_name}', '#{sql}')"
        execute(sql)
      end
      
      # Facet counts and results
      
      def population(relation, base, filters, facet)
        # Would be nice to use Arel here... but it isn't up to relational joins of this complexity
        signatures = (['_facet', '_base'] + filters.keys).map{ |key| "#{key}.signature"}
        
        clauses = []
        clauses << "(#{facet.to_sql}) AS _facet"
        clauses << "(#{base.to_sql})  AS _base"
        filters.each do |key, rel|
          clauses << "(#{rel.to_sql}) AS #{key}"
        end
        
        sql  = "SELECT _facet.#{relation.facet_name_value}, count(#{signatures.join(' & ')}) "
        sql += "FROM #{clauses.join(",\n")} "
        sql += "ORDER BY #{relation.order_values.join(', ')} " if relation.order_values.present?
        sql += "OFFSET #{relation.offset_value} "              if relation.offset_value.present?
        sql += "LIMIT #{relation.limit_value} "                if relation.limit_value.present?
        
        # run query and type cast
        results = query(sql)
        results = results.map { |key, count| [ key, count.to_i] }
        results = Hash[results]
        
        # minimums and nils
        results = results.reject { |key, count| count < (relation.minimum_value || 1) }
        results.delete(nil)                                    if relation.nils_value == false
        
        results
      end
      
      def filter_join_sql(filters)
        signatures = filters.values.map(&:to_sql)
        signatures = signatures.map { |sql| "(#{sql})" }
        "INNER JOIN members(#{signatures.join(' & ')}) AS _refinements_packed_id ON (_packed_id = _refinements_packed_id)"
      end
      
    end
  end
end