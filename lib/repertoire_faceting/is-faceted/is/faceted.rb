module DataMapper
  module Is
    module Faceted
      def is_faceted(*args)
        extend  DataMapper::Is::Faceted::ClassMethods
        include DataMapper::Is::Faceted::InstanceMethods
        
        # TODO.  A number of improvements could be made in the current faceting algorithm.
        #        (1) use a unique faceting id for models, which is kept packed
        #            (this could either be separate property on model, or a join table)
        #        (2) [alternatively] provide a packing function to compact model ids
        #            (this would require all foreign keys to be declared with ON UPDATE CASCADE)
        
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
          @facets[facet]
        end
      end

      module InstanceMethods
        def facet_count(*args)
          query = args.last.kind_of?(Hash) ? args.pop : {}
          facet = args.first
          
          raise "Property #{facet} must be declared as a facet" unless self.facet?(facet)
          # (1) detemine which parameters are facets and which are ordinary columns
          # (2) run the query with the ordinary columns.  this is the base signature
          # (3) run a sig_filter query with the facet columns.  this is the filter signature
          # (4) run a sig_count over all of the values on the facet to count          
        end
      end
    end
  end
end