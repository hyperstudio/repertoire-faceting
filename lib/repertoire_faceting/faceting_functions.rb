module Repertoire
  module Faceting
    module Functions

      # refinement on facets of current query model
      def facet_results(*args)
        query = args.last.kind_of?(Hash) ? args.pop : {}

        # parse facet-results specific arguments
        query_spec = FacetQuery.new do |fq|
          query, fq.refinements = parse_refinements(query)
          fq.adapter            = repository.adapter
          fq.logic              = default_logic(query.delete(:logic) || {})
          fq.base_query         = scoped_query(query)
        end
        
        return query_spec.facet_results
      end

      # facet value count on current query model
      def facet_count(*args)
        query   = args.last.kind_of?(Hash) ? args.pop : {}
        facet   = args.first.to_s

        raise "Property #{facet} must be declared as a facet" unless self.facet?(facet)
        if [:fields, :links, :unique, :add_reversed, :reload].any? { |o| query[o] }
          raise ":fields, :links, :unique, :add_reversed, :reload have no meaning for facet value counts"
        end
        
        # parse facet-count specific arguments
        query_spec = FacetQuery.new do |fq|
          query, fq.refinements = parse_refinements(query)
          fq.adapter            = repository.adapter
          fq.facet              = facet        
          fq.logic              = default_logic(query.delete(:logic) || {})
          fq.type               = query.delete(:type)    || String
          fq.minimum            = query.delete(:minimum) || (fq.logic[fq.facet] == :geom ? 0 : 1)
          fq.nullable           = query.delete(:nullable) != false
          fq.order              = query.delete(:order)   || [:count.desc, facet.to_sym.asc]
          fq.limit              = query.delete(:limit)
          fq.offset             = query.delete(:offset)  || 0
          fq.also               = query.delete(:also)    || []
        
          # any remaining items are DataMapper conditions for the base query
          fq.base_query           = scoped_query(query)
        end
        
        query_spec.facet_count
      end
      
      # name of facet index table
      def facet_storage_name(facet)
        "_#{storage_name}_#{facet}_facet"
      end
      
      # name of column used to construct signatures
      def signature_id_column
        "_packed_id"
      end
      
      private
      # use facet declarations as defaults overridden by argument logic
      def default_logic(logic)
        facet_expr.merge(logic.to_mash)
      end
      
      # normalize refinements into a hash of arrays
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
