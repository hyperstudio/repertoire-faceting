require 'active_support/ordered_hash'

module Repertoire
  module Faceting
    module PostgreSQLColumn
          
      # TODO.  still not clear how ActiveRecord adapters support adding custom SQL data types...
      #        feels like a monkey-patch, but there's no documented procedure
      def simplified_type(field_type)
        case field_type
          # Bitset signature type
        when 'signature'
          :string
        else
          super        
        end
      end
      
    end
    
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
      
      def population(facet, masks, signatures)
        # Would be nice to use Arel here... but it isn't up to relational joins of this complexity, 
        # despite best-effort attempts
        exprs = masks.map { |mask| "(#{mask.to_sql})" }
        
        sql  = "SELECT facet.#{facet.facet_name}, count(facet.signature & mask.signature) "
        sql += "FROM (SELECT (#{exprs.join(' & ')}) AS signature) AS mask, "
        sql += "     (#{signatures.to_sql}) AS facet "
        sql += "ORDER BY #{facet.order_values.join(', ')} " if facet.order_values.present?
        sql += "OFFSET #{facet.offset_value} "              if facet.offset_value.present?
        sql += "LIMIT #{facet.limit_value} "                if facet.limit_value.present?
        
        # run query and type cast
        results = query(sql)
        results = results.map { |key, count| [ key, count.to_i] }
        results = ActiveSupport::OrderedHash[results]
        
        # minimums and nils
        results = results.reject { |key, count| count < (facet.minimum_value || 1) }
        results.delete(nil)                           if facet.nils_value == false
        
        results
      end
      
      def mask_members_sql(masks)
        exprs = masks.map { |mask| "(#{mask.to_sql})" }
        "INNER JOIN members(#{exprs.join(' & ')}) AS _refinements_packed_id ON (_packed_id = _refinements_packed_id)"
      end
      
    end
  end
end