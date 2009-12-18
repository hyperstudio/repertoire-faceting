module Repertoire
  module Faceting
    class FacetQuery
      
      attr_accessor :adapter, :facet, :base_query, :refinements, 
                              :logic, :minimum, :nullable, :order, :limit, :offset, 
                              :type, :also

      def initialize(&block)
        @results = nil
        if (block_given?)
          yield self
        end
      end
      
      def facet_count
        adapter.facet_count(self)
      end
      
      def facet_results
        items = adapter.facet_results(self)
        base_query.model.load(items, base_query)
      end
    end
  end
end