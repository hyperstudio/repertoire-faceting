module DataMapper
  module Adapters
    class PostgresAdapter
      def signature(query, dummy_id_col, packed_id_col)
        stmt = read_statement(query)
        # TODO. hack -- should really be doneby over-riding property_to_column_name in DataObjects; see dm-aggregates
        stmt.gsub!(/SELECT "#{dummy_id_col}"/, "SELECT signature(#{packed_id_col})")
        stmt.gsub!(/ORDER BY .*$/, '')
        
        read_raw_one(stmt, [String], *query.bind_values)
      end
      
      def de_signature(model, base, filter, order)
        signatures = []
        signatures << "'#{base}'::signature" unless base.blank?
        signatures << "'#{filter}'::signature" unless filter.blank?
            
        stmt = <<SQL.compress_lines
          SELECT * FROM #{model.storage_name} WHERE contains(#{signatures.join(' & ')}, _packed_id)
SQL
        model.find_by_sql(stmt)
      end
      
      def filter(table_name, refinements)
        clauses = []
        bindings = []
        refinements.each do |facet, value|
          value = [value].flatten
          clauses << "SELECT signature FROM _#{table_name}_#{facet}_facet WHERE #{facet} IN ?"
          bindings << value
        end
        stmt = "SELECT filter(signature) FROM (#{clauses.join(' UNION ')}) AS refinements"
        read_raw_one(stmt, [String], bindings)
      end
      
      def facet_count(table_name, facet, base, filter, order)
        signatures = [ "signature"]
        signatures << "'#{base}'::signature" unless base.blank?
        signatures << "'#{filter}'::signature" unless filter.blank?
        
        stmt = <<SQL.compress_lines
          SELECT #{facet}, count FROM
            (SELECT #{facet}, count(#{signatures.join(' & ')})
             FROM _#{table_name}_#{facet}_facet) AS facet
SQL
        stmt << " WHERE count > 0"
        stmt << " ORDER BY #{raw_order_statement(order)}"

        # TODO. hack -- should be done by over-riding DataObjects
        stmt.gsub!(/ORDER BY id/, 'ORDER BY count DESC')

        read_raw_many(stmt, [String, Integer])
      end
      
      private
      # TODO. hack -- should use DataMapper query statement instead to model the facet index table?
      def raw_order_statement(order)
        order = order.map do |order_by|
          case order_by
            when Query::Direction
              "#{order_by.property} #{order_by.direction}"
            when Property
              "#{order_by.name}"
            when Query::Operator
              "#{order_by.target} #{order_by.operator}"
            when Symbol, String
              "#{order_by}"
          else
            raise ArgumentError, "+options[:order]+ entry #{order_by.inspect} not supported", caller(2)
          end
        end
        order.join(', ')
      end
      
      # read values without interpreting; also allow client to modify SQL
      def read_raw_one(stmt, types = nil, bind_values = nil, &block)
        with_connection do |connection|
          command = connection.create_command(stmt)
          command.set_types(types)
          begin
            reader = command.execute_reader(*bind_values)
            if reader.next!
              reader.values
            end
          ensure
            reader.close if reader
          end
        end
      end

      def read_raw_many(stmt, types = nil, bind_values = nil, &block)
        collection = []
        with_connection do |connection|
          command = connection.create_command(stmt)
          command.set_types(types)

          begin
            reader = command.execute_reader(*bind_values)
            while(reader.next!)
              collection << (reader.values)
            end
          ensure
            reader.close if reader
          end
        end
        collection
      end
    end
  end
end