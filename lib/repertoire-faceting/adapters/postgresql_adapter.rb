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
    
      # Returns the available in-database faceting APIs (only when installed as an extension)
      def api_bindings
        sql = "SELECT name FROM pg_available_extensions WHERE name LIKE 'faceting%';"
        select_values(sql)
      end
      
      # Returns the currently active faceting API binding (only when installed as an extension)
      def current_api_binding
        sql = "SELECT name FROM pg_extension WHERE name LIKE 'faceting%';"
        select_value(sql)
      end
    
      # Creates (or recreates) the packed id column on a given table
      def renumber_table(table_name, faceting_id, wastage)
        sql = "SELECT facet.renumber_table('#{table_name}', '#{faceting_id}', #{wastage})"
        execute(sql)
      end

      # Returns the scatter quotient of the given id column
      def signature_wastage(table_name, faceting_id)
        sql    = "SELECT facet.signature_wastage('#{table_name}', '#{faceting_id}')"
        result = select_value(sql)
        Float(result)
      end

      # Creates (recreates) a table with the specified select statement
      def recreate_table(table_name, sql)
        sql = "SELECT facet.recreate_table('#{table_name}', $$#{sql}$$)"
        execute(sql)
        
        puts "SQL : #{sql}"
        puts "SHould be a new table: #{table_name}.  Trying..."
        
        indexed = ActiveRecord::Base.connection.select_value("SELECT count(*) FROM #{table_name}");
        puts "INDExED #{indexed}"
      end
      
      # Returns path to the named PostgreSQL API binding file
      def faceting_api_sql(api_name = :signature)
        api_name = api_name.to_sym
        raise "Use 'CREATE EXTENSION faceting' to load the default facet api" if api_name == :signature
        
        path = Repertoire::Faceting::MODULE_PATH
        version = Repertoire::Faceting::VERSION
        sql << File.load("#{path}/ext/faceting_#{api_name}--#{version}.sql").replace('@extschema@', 'facet')
        
        sql
      end

      # Expands nested faceting for the specified table (once)
      def expand_nesting(table_name)
        sql = "SELECT facet.expand_nesting('#{table_name}')"
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
        results.reject! { |key, count| count < (facet.minimum_value || 1) }
        results.delete(nil)            if facet.nils_value == :exclude

        results
      end

      def mask_members_sql(masks, table_name, faceting_id)
        exprs = masks.map { |mask| "(#{mask.to_sql})" }
        "INNER JOIN facet.members(#{exprs.join(' & ')}) AS _refinements_id ON (#{table_name}.#{faceting_id} = _refinements_id)"
      end
      
    end
  end
end