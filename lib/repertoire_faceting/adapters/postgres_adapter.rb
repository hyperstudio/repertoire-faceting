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
        facet_statement = facet_statement(model, facet, refinements, logic)
        conditions = []
        conditions << "count >= #{count_minimum}"        if count_minimum > 0
        conditions << "#{quote_name(facet)} IS NOT NULL" if !nullable
        
        nesting_point = nesting_level ? "[#{nesting_level}]" : ""
        
        statement = "SELECT #{quote_name(facet)}, count FROM ("
        statement << "SELECT #{quote_name(facet)}#{nesting_point}, count(facet.signature & base.signature)"
        statement << " FROM #{facet_statement} AS facet, #{base_signature_statement} AS base"
        statement << ") AS facet_counts"
        statement << " WHERE #{conditions.join(' AND ')}" unless conditions.empty?
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
        
        statement = "SELECT #{columns_statement(fields, qualify)}"
        statement << " FROM #{quote_name(model.storage_name(name))}, (#{base_signature_statement}) AS facet_results"
        statement << " WHERE contains(facet_results.signature, #{quote_name(model.signature_id_column)})"
        statement << " ORDER BY #{order_statement(order_by, qualify)}"   if order_by && order_by.any?

        add_limit_offset!(statement, limit, offset, bind_values)
        
        read_hash_from_sql(fields, statement, bind_values)
      end
        
      private  
      
      def facet_statement(model, facet, refinements, logic)
        if logic[facet] == :nested
          nesting_level = refinement_nesting_level(facet, refinements, logic)
          nesting_range = "[1:#{nesting_level}]"
          
          expr = "(SELECT #{quote_name(facet)}#{ nesting_range } AS #{quote_name(facet)}, collect(signature) AS signature"
          expr << " FROM #{quote_name(model.facet_storage_name(facet))}"
          expr << " GROUP BY #{quote_name(facet)}#{ nesting_range })"
        else # and- or or- style facet
          expr = quote_name(model.facet_storage_name(facet))
        end
      end
      
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
        refinements_statement, bind_values = refinements_statement(model, refinements, logic, bind_values)
      
        statement =  "(SELECT filter(signature) AS signature FROM ("
        statement << "SELECT signature(#{quote_name(model.signature_id_column)}) FROM #{quote_name(model.storage_name(name))}"
        unless conditions_statement.blank?
          statement << " WHERE #{conditions_statement}"
        end
        unless refinements_statement.blank?
          statement << " UNION #{refinements_statement}"
        end
        statement << ") AS filter)"

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
        
        return statements.join(' UNION '), bind_values
      end
      
      def facet_value_conditions(facet, values, logic)
        placeholders = values.map { '?' }
        statement = []
        if logic[facet] == :nested
          values.each_with_index do |v, i|
            statement << " #{quote_name(facet.to_s)}[#{i+1}] = ?"
          end
        else
          statement << " #{quote_name(facet.to_s)} IN (#{placeholders.join(', ')})"
        end
        statement.join(' AND ')
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