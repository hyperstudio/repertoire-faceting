module DataMapper
  module Is
    module Faceted
      def is_faceted(*args)
        extend  DataMapper::Is::Faceted::ClassMethods
        include DataMapper::Is::Faceted::InstanceMethods
        
        # parse facet declarations
        @facets  = args.last.kind_of?(Hash) ? args.pop : {}
        args.each { |facet| @facets[facet] = facet }

        @facets.keys
      end
        
      module ClassMethods
        def facets
          @facets.keys
        end
        
        def facet?(property_name)
          self.facets.include?(property_name)
        end
        
        def facet_expr(facet)
          # not currently used
          @facets[facet]
        end
        
        def facet_count(*args)
          query = args.last.kind_of?(Hash) ? args.pop : {}
          facet = args.first

          raise "Property #{facet} must be declared as a facet" unless self.facet?(facet)
          
          adapter = query.repository.adapter
          
          # (1) extract facet refinements from query
          refinements = query.only(*@facets.keys)
          query.delete_if { |k, v| facet?(k) }
          order       = query.delete(:order) || [:count.desc]

          # (2) run the query with the ordinary columns.  this is the base signature (as a string)
          query[:fields] = [:id]
          base = adapter.signature(scoped_query(query))

          # (3) run a signature filter query with the facet columns.  this is the filter signature (as a string)
          filter = refinements.empty? ? nil : adapter.filter(storage_name, refinements)

          # (4) run a count over all of the values on the facet to count
          counts = adapter.facet_count(storage_name, facet, base, filter, order)

          return counts
        end

        def facet_result(*args)
        end
      end

      module InstanceMethods
      end
    end
  end
end
