module Repertoire
  module Faceting
    module PostgresAdapter
      
      def self.included(base)
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          alias select_statement_without_refinement select_statement
          alias select_statement select_statement_with_refinement
        RUBY
      end
      
      # execute a facet value count query
      def facet(facet, base_query, facet_count_query)
      end
      
      # Constructs SELECT statement for given query,
      #
      # @return [String] SELECT statement as a string
      #
      # @api private
      def select_statement_with_refinement(query)
        if query.refinements.blank?
          # if no facet refinements, run standard DataMapper select
          statement, bind_values = select_statement_without_refinement(query)
        else
          # use base and filter as signature as subselect, then get model fields
          raise "Facet refinement cannot be used with links (yet!)" if query.links.any?          
          
          # much-simplified adaptation of standard select statement
          model      = query.model
          fields     = query.fields
          refinements = query.refinements
          conditions = query.conditions
          limit      = query.limit
          offset     = query.offset
          order_by   = query.order
          qualify    = false

          base_signature_statement, bind_values = base_signature_statement(query)
          
          statement = "SELECT #{columns_statement(fields, qualify)}"
          statement << " FROM #{quote_name(model.storage_name(name))}, (#{base_signature_statement}) AS base"
          statement << " WHERE contains(base.signature, #{quote_name(model.signature_id_column)})"
          statement << " ORDER BY #{order_statement(order_by, qualify)}"   if order_by && order_by.any?

          add_limit_offset!(statement, limit, offset, bind_values)
        end
        
        return statement, bind_values
      end
        
      def base_signature_statement(query)
        model       = query.model
        conditions  = query.conditions
        refinements = query.refinements
        qualify     = false

        conditions_statement, bind_values = conditions_statement(conditions, qualify)
        refinements_statement, bind_values = refinements_statement(model, refinements, bind_values)
      
        statement =  "SELECT filter(signature) AS signature FROM ("
        unless conditions_statement.blank?
          statement << "SELECT signature(#{quote_name(model.signature_id_column)}) FROM #{quote_name(model.storage_name(name))}"
          statement << " WHERE #{conditions_statement}"
          statement << " UNION #{refinements_statement}"
        else
          statement << " #{refinements_statement}"
        end
        statement << ") AS filter"

        return statement, bind_values
      end
      
      def refinements_statement(model, refinements, bind_values=[])
        # TODO.  when and/or available within refinements, switch between collect/filter in aggregate below
        statements = []
        refinements.each do |facet, values|
          placeholders = values.map { '?' }
          statements << "SELECT collect(signature) AS signature FROM #{quote_name(model.facet_storage_name(facet))}" +
                        " WHERE #{quote_name(facet)} IN (#{placeholders.join(', ')})"
          bind_values += values
        end
        
        return statements.join(' UNION '), bind_values
      end
    end
  end
end