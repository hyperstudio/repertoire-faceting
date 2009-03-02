module DataMapper
  module Is
    module Faceted
      def is_faceted(*args)
        extend  DataMapper::Is::Faceted::ClassMethods
        include DataMapper::Is::Faceted::InstanceMethods
        
        # parse facet declarations
        @facets  = args.last.kind_of?(Hash) ? args.pop : {}
        args.each { |facet| @facets[facet] = facet }
        @facets = @facets.to_mash

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
      end

      module InstanceMethods
      end
    end
  end
end
