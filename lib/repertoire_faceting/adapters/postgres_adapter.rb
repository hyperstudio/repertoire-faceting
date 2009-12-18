module Repertoire
  module Faceting
    module PostgresAdapter
      
      # TODO.  abstract out the logic-specific elements here into a pluggable architecture for producing sql
      
      # execute a facet value count query
      def facet_count(fq)
        # much-simplified adaptation of standard select statement
        q = fq.base_query

        base_signature_statement, bind_values = base_signature_statement(fq.base_query, fq.refinements, fq.logic)
        refinements_statement, bind_values    = refinements_statement(fq.base_query.model, fq.refinements, fq.logic, bind_values)

        signature_expr = ["facet.signature"]
        signature_expr << "base.signature"   unless base_signature_statement.empty?
        signature_expr << "filter.signature" unless refinements_statement.empty?

        nesting_level    = refinement_nesting_level(fq.facet, fq.refinements, fq.logic)
        nesting_point    = nesting_level ? "[#{nesting_level}]" : ""

        return_fields = [ "#{quote_name(fq.facet)}", "count" ]
        return_types  = [ String, Integer ]
        facet_fields  = [ "#{quote_name(fq.facet)}#{nesting_point}", "count(#{signature_expr.join(' & ')})" ]
        extra_fields(fq) do |expr, type, index|
          return_fields << "extra#{index}"
          return_types  << type
          facet_fields  << "#{expr} AS extra#{index}"
        end

        pivot_statement  = ""
        pivot_conditions = []
        case fq.logic[fq.facet]
        when :nested
          pivot_conditions << "array_length(#{quote_name(fq.facet)}, 1) = ?" if nesting_level
          bind_values      << nesting_level                                  if nesting_level
        when :geom
          if fq.refinements[fq.facet]
            pivot_statement   = "SELECT #{quote_name(fq.facet)} as pivot_key, full_geom AS pivot_geom, layer AS pivot_layer FROM #{quote_name(q.model.facet_storage_name(fq.facet))}"
            pivot_conditions << "ST_Within(full_geom, pivot_geom)"
            pivot_conditions << "layer = pivot_layer + 1"
            pivot_conditions << "pivot_key = ?"
            bind_values      << fq.refinements[fq.facet].first
          else
            pivot_conditions << "facet.layer = 1"
          end
        end

        facet_conditions = []
        facet_conditions << "count >= #{fq.minimum}"              if fq.minimum > 0
        facet_conditions << "#{quote_name(fq.facet)} IS NOT NULL" if !fq.nullable
        
        facet_count_order_statement = facet_count_order_statement(fq.facet, fq.order, facet_fields)
        
        statement =  "SELECT #{return_fields.join(', ')} FROM ("
        statement << "SELECT #{facet_fields.join(', ')}"
        statement << " FROM #{quote_name(q.model.facet_storage_name(fq.facet))} AS facet"
        statement << ", (#{base_signature_statement}) AS base"        unless base_signature_statement.empty?
        statement << ", (#{refinements_statement}) AS filter"         unless refinements_statement.empty?
        statement << ", (#{pivot_statement}) AS pivot"                unless pivot_statement.empty?
        statement << " WHERE #{pivot_conditions.join(' AND ')}"       unless pivot_conditions.empty?
        statement << ") AS facet_counts"
        statement << " WHERE #{facet_conditions.join(' AND ')}"       unless facet_conditions.empty?
        statement << " ORDER BY #{facet_count_order_statement}"       unless facet_count_order_statement.empty?

        read_array_from_sql(return_types, statement, bind_values)
      end
      
      # Constructs SELECT statement for given query,
      #
      # @return [String] SELECT statement as a string
      #
      # @api private
      def facet_results(fq)
        # use base and filter as signature as subselect, then get model fields
        
        # much-simplified adaptation of standard select statement
        q       = fq.base_query
        qualify = false

        base_signature_statement, bind_values = base_signature_statement(q, fq.refinements, fq.logic)
        refinements_statement, bind_values    = refinements_statement(q.model, fq.refinements, fq.logic, bind_values)
        
        signature_expr = []
        signature_expr << "base.signature"   unless base_signature_statement.empty?
        signature_expr << "filter.signature" unless refinements_statement.empty?
        
        faceted_expr = []
        faceted_expr << "(#{base_signature_statement}) AS base"   unless base_signature_statement.empty?
        faceted_expr << "(#{refinements_statement}) AS filter"    unless refinements_statement.empty?
        
        statement = "SELECT #{columns_statement(q.fields, qualify)}"
        statement << " FROM #{quote_name(q.model.storage_name(name))}"
        unless signature_expr.empty?
          statement << ", (SELECT members(#{signature_expr.join(' & ')}) FROM "
          statement << faceted_expr.join(', ')
          statement << ") AS faceted"
          statement << " WHERE #{quote_name(q.model.storage_name(name))}.#{quote_name(q.model.signature_id_column)} = faceted.members"
        end
        statement << " ORDER BY #{order_statement(q.order, qualify)}"   if q.order && q.order.any?

        add_limit_offset!(statement, q.limit, q.offset, bind_values)
        
        read_hash_from_sql(q.fields, statement, bind_values)
      end
        
      private
      
      def refinement_nesting_level(facet, refinements, logic)
        case
        when logic[facet] != :nested then nil
        when refinements[facet].nil? then 1
        else refinements[facet].length + 1
        end
      end
      
      def facet_count_order_statement(facet, order, facet_fields)
        # TODO.  make ordering more flexible; add to facet_fields
        facet_sym = facet.to_sym
        statement = []
        order.each do |field|
          statement << case field
          when :count.desc then                     "count DESC"
          when :count.asc, :count, 'count' then     "count ASC" 
          when facet_sym.desc then                  "#{facet} DESC"
          when facet_sym.asc, facet_sym, facet then "#{facet} ASC"
          when :id.asc, :id, 'id' then              facet_fields << "id"; "id ASC"
          else raise "Unkown order: #{order}"
          end
        end        
        statement.join(', ')
      end
      
      def base_signature_statement(base_query, refinements, logic)
        model       = base_query.model
        conditions  = base_query.conditions
        qualify     = false

        conditions_statement, bind_values = conditions_statement(conditions, qualify)

        statement = ""
        unless conditions_statement.blank?
          statement << "SELECT signature(#{quote_name(model.signature_id_column)}) FROM #{quote_name(model.storage_name(name))}"
          statement << " WHERE #{conditions_statement}"
        end

        return statement, bind_values
      end

      def refinements_statement(model, refinements, logic, bind_values=[])
        statements = []
        refinements.each do |facet, values|
          facet_value_conditions = facet_value_conditions(facet, values, logic)

          aggregate_fn = case logic[facet]
          when nil, :and           then 'filter'
          when :or, :nested, :geom then 'collect'
          else raise "Unkown facet refinement logic option: #{logic[facet]}"
          end

          expr = "SELECT #{aggregate_fn}(signature) AS signature"
          expr << " FROM #{quote_name(model.facet_storage_name(facet))}"
          expr << " WHERE #{facet_value_conditions}"
          statements << expr
          bind_values += values
        end
        
        filtered_stmt = ""
        filtered_stmt << "SELECT filter(signature) AS signature FROM (#{statements.join(' UNION ')}) AS filter_elems" unless statements.empty?
        
        return filtered_stmt, bind_values
      end
      
      def facet_value_conditions(facet, values, logic)
        placeholders = values.map { '?' }
        statement = case logic[facet]
          when :nested then " #{quote_name(facet.to_s)} = ARRAY [ #{placeholders.join(', ')} ]"
          else              " #{quote_name(facet.to_s)} IN (#{placeholders.join(', ')})"
        end
        return statement
      end

      def extra_fields(fq)
        case fq.logic[fq.facet]
        when :geom
          yield "label", String, 2
          yield "ST_AsKML(display_geom)", String, 3
          yield "GeometryType(display_geom)", String, 4
          yield "ST_AsKML(ST_PointOnSurface(display_geom))", String, 5
        end
      end
      
      def read_hash_from_sql(fields, statement, bind_values)
        types  = fields.map { |property| property.primitive }
        records = []

        with_connection do |connection|
          command = connection.create_command(statement)
          command.set_types(types)

          reader = command.execute_reader(*bind_values)

          begin
            while reader.next!
              records << fields.zip(reader.values).to_hash
            end
          ensure
            reader.close
          end
        end

        records
      end
      
      def read_array_from_sql(types, statement, bind_values)
        records = []

        with_connection do |connection|
          command = connection.create_command(statement)
          command.set_types(types)

          reader = command.execute_reader(*bind_values)

          begin
            while reader.next!
              records << reader.values
            end
          ensure
            reader.close
          end
        end

        records
      end
    end
  end
end