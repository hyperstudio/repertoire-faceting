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

      #
      # Methods for accessing faceting APIs (as PostgreSQL extensions)
      #

      # Returns the available in-database faceting APIs (only when installed as an extension)
      def facet_api_bindings
        @api_bindings ||= select_values "SELECT name FROM pg_available_extensions WHERE name LIKE 'faceting%'"
      end

      # Returns the currently active faceting API binding (only when installed as an extension)
      def current_facet_api_binding
        @current_api_binding ||= select_value "SELECT extname FROM pg_extension WHERE extname LIKE 'faceting%';"
      end

      #
      # Methods for access to facet indices
      #

      def facet_schema
        # TODO. Not clear how to get the schema associated with a PostgreSQL extension from the
        #       system tables. So we limit to loading into a schema named 'facet' for now.
        'facet'
      end

      def facet_table_name(model_name, name)
        "#{facet_schema}.#{model_name}_#{name}_index"
      end

      def indexed_facets(model_name)
        sql = "SELECT matviewname FROM pg_matviews WHERE schemaname = 'facet'"
        tables = select_values(sql)

        tables.grep(/#{model_name}_(\w+)_(\d*)?index/) { $1 }
      end

      #
      # Methods for managing packed id columns on models
      #

      def signature_wastage(table_name, faceting_id)
        sql = "SELECT #{facet_schema}.wastage(#{faceting_id}) FROM #{table_name}"
        result = select_value(sql)
        Float(result)
      end

      #
      # Methods for detecting table content changes
      #
      # (If a later version of PostgreSQL can hashcode a table/timestamp in the system catalog,
      # switch to use that instead.)
      #
      def stat_table(table_name, column="updated_at")
        sql = "SELECT COUNT(#{column}), MAX(#{column}) AS timestamp FROM #{table_name}"
        result = select_one(sql)
        result = HashWithIndifferentAccess.new({
          :count     => Integer(result["count"]),
          :timestamp => Time.parse(result["timestamp"])
        })

        result
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

        bit_and = " OPERATOR(#{facet_schema}.&) "

        sql  = "SELECT fct.#{facet.facet_name}, #{facet_schema}.count(#{ sigs.join(bit_and) }) "
        sql += "FROM (#{signatures.to_sql}) AS fct "
        sql += ", (SELECT (#{exprs.join(bit_and)}) AS signature) AS mask " unless masks.empty?
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
        bit_and = " OPERATOR(#{facet_schema}.&) "
        exprs = masks.map { |mask| "(#{mask.to_sql})" }
        "INNER JOIN #{facet_schema}.members(#{exprs.join(bit_and)}) AS _refinements_id ON (#{table_name}.#{faceting_id} = _refinements_id)"
      end


      module MigrationMethods #:nodoc:

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

        # Returns the named PostgreSQL API binding sql; for shared hosts where you cannot build extensions
        def faceting_api_sql(api_name, schema_name)
          path        = Repertoire::Faceting::MODULE_PATH
          version     = Repertoire::Faceting::VERSION
          api_name    = api_name.to_sym
          file_name   = "#{path}/ext/#{api_name}/faceting_#{api_name}--#{version}.sql"

          raise "Use 'CREATE EXTENSION faceting' to load the default facet api"        if api_name == :signature
          raise "Currently, the faceting API must install into a schema named 'facet'" unless schema_name == facet_schema

          # TODO This approach allows production deploys to skip a "rake db:extensions:install" step when installing
          #      to Heroku. In practice, this eases deployment significantly. But shelling out to make during a
          #      Rails migration feels inelegant.
          system "cd #{path}/ext; make"                    unless File.exist?(file_name)
          raise "No API binding available for #{api_name}" unless File.exist?(file_name)

          File.read(file_name).gsub(/@extschema@/, facet_schema)
        end
      end

      include MigrationMethods

    end
  end
end
