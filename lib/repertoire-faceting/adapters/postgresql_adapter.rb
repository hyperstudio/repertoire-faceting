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

      FACET_SCHEMA = 'facet'
      BIT_AND      = " OPERATOR(#{FACET_SCHEMA}.&) "

      #
      # Over-ride default functionality in abstract adapter
      #

      def facet_table_name(model_name, name)
        "#{FACET_SCHEMA}.#{model_name}_#{name}_index"
      end

      def indexed_facets(model_name)
        sql = "SELECT matviewname FROM pg_matviews WHERE schemaname = 'facet'"
        tables = select_values(sql)

        tables.grep(/#{model_name}_(\w+)_(\d*)?index/) { $1 }
      end

      #
      # Methods for accessing faceting APIs (as PostgreSQL extensions)
      #

      # Returns the available in-database faceting APIs (only when installed as an extension)
      def facet_api_bindings
        sql = "SELECT name FROM pg_available_extensions WHERE name LIKE 'faceting%';"
        select_values(sql)
      end

      # Returns the currently active faceting API binding (only when installed as an extension)
      def current_facet_api_binding
        sql = "SELECT extname FROM pg_extension WHERE extname LIKE 'faceting%';"
        select_value(sql)
      end

      # Returns path to the named PostgreSQL API binding file
      def faceting_api_sql(api_name = :signature)
        api_name  = api_name.to_sym
        file_name = "#{path}/ext/faceting_#{api_name}--#{version}.sql"

        raise "Use 'CREATE EXTENSION faceting' to load the default facet api" if api_name == :signature
        raise "No API binding available for #{api_name}.\n" +
              "(Did you build the apis with 'rake db:faceting:extensions:build'?)" unless File.exist?(file_name)

        path = Repertoire::Faceting::MODULE_PATH
        version = Repertoire::Faceting::VERSION
        sql << File.load(file_name).replace('@extschema@', 'facet')

        sql
      end

      #
      # Methods used in creating, updating, and removing facet indices
      #

      def create_materialized_view(view_name, sql)
        sql = "CREATE MATERIALIZED VIEW #{quote_table_name(view_name)} AS #{sql}"
        execute(sql)
      end

      def refresh_materialized_view(view_name)
        sql = "REFRESH MATERIALIZED VIEW #{quote_table_name(view_name)}"
        execute(sql)
      end

      def drop_materialized_view(view_name)
        sql = "DROP MATERIALIZED VIEW #{quote_table_name(view_name)} CASCADE"
        execute(sql)
      end

      #
      # Methods for managing packed id columns on models
      #

      def signature_wastage(table_name, faceting_id)
        sql = "SELECT #{FACET_SCHEMA}.wastage(#{faceting_id}) FROM #{table_name}"
        result = select_value(sql)
        Float(result)
      end

      #
      # Methods for running facet value counts
      #

      def population(facet, masks, signatures)
        # Would be nice to use Arel here... but recent versions (~ 2.0.1) have removed the property of closure under
        # composition (e.g. joining two select managers / sub-selects)... why?!?
        sigs  = [ 'fct.signature' ]
        exprs = masks.map{|mask| "(#{mask.to_sql})"}
        sigs << 'mask.signature' unless masks.empty?
        
        sql  = "SELECT fct.#{facet.facet_name}, #{FACET_SCHEMA}.count(#{ sigs.join(BIT_AND) }) "
        sql += "FROM (#{signatures.to_sql}) AS fct "
        sql += ", (SELECT (#{exprs.join(BIT_AND)}) AS signature) AS mask " unless masks.empty?
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
        "INNER JOIN #{FACET_SCHEMA}.members(#{exprs.join(BIT_AND)}) AS _refinements_id ON (#{table_name}.#{faceting_id} = _refinements_id)"
      end

    end
  end
end