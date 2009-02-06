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
          
          # (1) detemine which parameters are facets and which are ordinary columns
          # (2) run the query with the ordinary columns.  this is the base signature
          # (3) run a sig_filter query with the facet columns.  this is the filter signature
          # (4) run a count over all of the values on the facet to count          
        end

        def facet_result(*args)
        end
      end

      module InstanceMethods
      end
    end
  end
end
