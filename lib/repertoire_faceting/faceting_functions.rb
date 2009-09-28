module Repertoire
  module Faceting
    module Functions

      # refinement on facets of current query model
      def refine(*args)
        refinements = args.last.kind_of?(Hash) ? args.pop : {}
      
        raise "Only facets are allowed in refine()" unless refinements.keys.all? { |k| facet?(k) }
        
        refined_query = scoped_query(self.query.dup)
        refined_query.merge_refinements(refinements)
        
        return new_collection(refined_query)
      end
      
      # facet value count on current query model.  executes immediately
      def facet(*args)
        query = args.last.kind_of?(Hash) ? args.pop : {}
        facet = args.first

        raise "Property #{facet} must be declared as a facet" unless self.facet?(facet)
        
        # set the model
        query.model = 'NobelistDisciplineFacetCount'  # e.g.
        
        repository.adapter.facet(facet, self.query, scoped_query(query))
      end
      
      # name of facet index table
      def facet_storage_name(facet)
        "_#{storage_name}_#{facet}_facet"
      end
      
      def signature_id_column
        "_packed_id"
      end
    end
  end
end
