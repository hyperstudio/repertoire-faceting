module Repertoire
  module Faceting
    module PostgresAdapter
      
      # execute a facet value count query
      def facet_count(facet, query, refinements, count_minimum, count_order, count_limit, count_offset, logic = {}, nullable = true, type = String)
        # TODO.  simplify this method's parameters
        # much-simplified adaptation of standard select statement
        model         = query.model
        conditions    = query.conditions
        nesting_level = refinement_nesting_level(facet, refinements, logic)
        
        base_signature_statement, bind_values = base_signature_statement(query, refinements, logic)
        refinements_statement, bind_values    = refinements_statement(model, refinements, logic, bind_values)
        
        nesting_point = nesting_level ? "[#{nesting_level}]" : ""
        
        signature_expr = ["facet.signature"]
        signature_expr << "base.signature"   unless base_signature_statement.empty?
        signature_expr << "filter.signature" unless refinements_statement.empty?
        
        inner_conditions = []
        if nesting_level
          inner_conditions << "array_length(#{quote_name(facet)}, 1) = ?"
          bind_values      << nesting_level
        end
        
        outer_conditions = []
        outer_conditions << "count >= #{count_minimum}"        if count_minimum > 0
        outer_conditions << "#{quote_name(facet)} IS NOT NULL" if !nullable
        
        statement =  "SELECT #{quote_name(facet)}, count FROM ("
        statement << "SELECT #{quote_name(facet)}#{nesting_point}, count(#{signature_expr.join(' & ')})"
        statement << " FROM #{quote_name(model.facet_storage_name(facet))} AS facet"
        statement << ", (#{base_signature_statement}) AS base"        unless base_signature_statement.empty?
        statement << ", (#{refinements_statement}) AS filter"         unless refinements_statement.empty?
        statement << " WHERE #{inner_conditions}"                     unless inner_conditions.empty?
        statement << ") AS facet_counts"
        statement << " WHERE #{outer_conditions.join(' AND ')}"       unless outer_conditions.empty?
        statement << " ORDER BY #{facet_count_order_statement(facet, count_order)}"

        read_array_from_sql([type, Integer], statement, bind_values)
      end
      
      # Constructs SELECT statement for given query,
      #
      # @return [String] SELECT statement as a string
      #
      # @api private
      def facet_results(query, refinements, logic={})
        # use base and filter as signature as subselect, then get model fields
        raise "Facet refinement cannot be used with links (yet!)" if query.links.any?
        
        # much-simplified adaptation of standard select statement
        model      = query.model
        fields     = query.fields
        conditions = query.conditions
        limit      = query.limit
        offset     = query.offset
        order_by   = query.order
        qualify    = false

        base_signature_statement, bind_values = base_signature_statement(query, refinements, logic)
        refinements_statement, bind_values    = refinements_statement(model, refinements, logic, bind_values)
        
        signature_expr = []
        signature_expr << "base.signature"   unless base_signature_statement.empty?
        signature_expr << "filter.signature" unless refinements_statement.empty?
        
        faceted_expr = []
        faceted_expr << "(#{base_signature_statement}) AS base"   unless base_signature_statement.empty?
        faceted_expr << "(#{refinements_statement}) AS filter"    unless refinements_statement.empty?
        
        statement = "SELECT #{columns_statement(fields, qualify)}"
        statement << " FROM #{quote_name(model.storage_name(name))}"
        unless signature_expr.empty?
          statement << ", (SELECT members(#{signature_expr.join(' & ')}) FROM "
          statement << faceted_expr.join(', ')
          statement << ") AS faceted"
          statement << " WHERE #{quote_name(model.storage_name(name))}.#{quote_name(model.signature_id_column)} = faceted.members"
        end
        statement << " ORDER BY #{order_statement(order_by, qualify)}"   if order_by && order_by.any?

        add_limit_offset!(statement, limit, offset, bind_values)
        
        read_hash_from_sql(fields, statement, bind_values)
      end
        
      private
      
      def refinement_nesting_level(facet, refinements, logic)
        case
        when logic[facet] != :nested then nil
        when refinements[facet].nil? then 1
        else refinements[facet].length + 1
        end
      end
      
      def facet_count_order_statement(facet, order)
        facet_sym = facet.to_sym
        statement = []
        order.each do |field|
          statement << case field
          when :count.desc then                     "count DESC"
          when :count.asc, :count, 'count' then     "count ASC" 
          when facet_sym.desc then                  "#{facet} DESC"
          when facet_sym.asc, facet_sym, facet then "#{facet} ASC"
          else raise "Unkown order: #{order}"
          end
        end        
        statement.join(', ')
      end
      
      def base_signature_statement(query, refinements, logic)
        model       = query.model
        conditions  = query.conditions
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
          when nil, :and    then 'filter'
          when :or, :nested then 'collect'
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