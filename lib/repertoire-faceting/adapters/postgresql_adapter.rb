require 'active_support/ordered_hash'

module Repertoire
  module Faceting
    module PostgreSQLColumn #:nodoc:
          
      # TODO.  still not clear how ActiveRecord adapters support adding custom SQL data types...
      #        feels like a monkey-patch, but there's no documented way to accomplish this simple task
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
    
    module PostgreSQLAdapter #:nodoc:
      
      # Creates (or recreates) the packed id column on a given table
      def renumber_table(table_name, faceting_id='_packed_id')
        sql = "SELECT renumber_table('#{table_name}', '#{faceting_id}')"
        execute(sql)
      end

      # Returns the scatter quotient of the given id column
      def signature_wastage(table_name, faceting_id='_packed_id')
        sql    = "SELECT signature_wastage('#{table_name}', '#{faceting_id}')"
        result = select_value(sql)
        Float(result)
      end
      
      # Creates (recreates) a table with the specified select statement
      def recreate_table(table_name, sql)
        sql = "SELECT recreate_table('#{table_name}', $$#{sql}$$)"
        execute(sql)
      end
      
      # Load PostgreSQL native bitset type into current database
      def load_faceting
        sql = File.read(Repertoire::Faceting::MODULE_PATH + '/ext/signature.sql')
        unload_faceting
        execute(sql)
      end
      
      # Unloads PostgreSQL native bitset type
      def unload_faceting
        execute("DROP TYPE IF EXISTS signature CASCADE")
      end
      
      # Expands nested faceting for the specified table (once)
      def expand_nesting(table_name)
        sql = "SELECT expand_nesting('#{table_name}')"
        execute(sql)
      end
      
      def population(facet, masks, signatures)
        # Would be nice to use Arel here... but recent versions (~ 2.0.1) have removed the property of closure under
        # composition (e.g. joining two select managers / sub-selects)... why?!?
        sigs  = [ 'facet.signature' ]
        exprs = masks.map{|mask| "(#{mask.to_sql})"}
        sigs << 'mask.signature' unless masks.empty?
        
        sql  = "SELECT facet.#{facet.facet_name}, count(#{ sigs.join(' & ')}) "
        sql += "FROM (#{signatures.to_sql}) AS facet "
        sql += ", (SELECT (#{exprs.join(' & ')}) AS signature) AS mask " unless masks.empty?
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
      
      def mask_members_sql(masks, table_name, faceting_id)
        exprs = masks.map { |mask| "(#{mask.to_sql})" }
        "INNER JOIN members(#{exprs.join(' & ')}) AS _refinements_id ON (#{table_name}.#{faceting_id} = _refinements_id)"
      end
      
      private
      
      def ignoring_db_errors(&block)
        begin
          yield
        rescue
        end
      end
      
    end
  end
end