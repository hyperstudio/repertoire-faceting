module Repertoire
  module Faceting
    module Functions

      # refinement on facets of current query model
      def facet_results(*args)
        query = args.last.kind_of?(Hash) ? args.pop : {}
        adapter = repository.adapter

        query, refinements = parse_refinements(query)
        raise "No facet refinements provided" if refinements.empty?

        # run facet refinement query
        query  = scoped_query(query)
        items  = adapter.facet_results(query, refinements)
        result = query.model.load(items, query)
        
        return result
      end
      
      # facet value count on current query model
      def facet_count(*args)
        query   = args.last.kind_of?(Hash) ? args.pop : {}
        facet   = args.first.to_s
        nested  = nested_facet?(facet)
        adapter = repository.adapter

        raise "Property #{facet} must be declared as a facet" unless self.facet?(facet)
        if [:fields, :links, :unique, :add_reversed, :reload].any? { |o| query[o] }
          raise ":fields, :links, :unique, :add_reversed, :reload have no meaning for facet value counts"
        end
        
        # parse facet-count specific arguments
        query, refinements = parse_refinements(query)
        minimum            = query.delete(:minimum) || 1
        order              = query.delete(:order) || [:count.desc, facet.to_sym.asc]
        limit              = query.delete(:limit)
        offset             = query.delete(:offset) || 0
        
        # run facet count query
        base_query  = scoped_query(query)
        result = adapter.facet_count(facet, base_query, refinements, minimum, order, limit, offset, nested)
        
        return result
      end
      
      # name of facet index table
      def facet_storage_name(facet)
        "_#{storage_name}_#{facet}_facet"
      end
      
      def signature_id_column
        "_packed_id"
      end
      
      private
      def parse_refinements(query)
        # extract facet refinements from query
        refinements = query.delete(:refinements) || query.to_mash.only(*facets)
        refinements = refinements.to_mash
        query.delete_if { |k, v| refinements.key?(k) }

        # normalize values to arrays
        refinements.each_pair do |facet, values|
          refinements[facet] = [values].flatten
        end
        
        return query, refinements
      end
    end
  end
end
