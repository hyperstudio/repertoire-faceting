module DataMapper
  module Is
    module Faceted
      def is_faceted(*args)
        extend  DataMapper::Is::Faceted::ClassMethods
        include DataMapper::Is::Faceted::InstanceMethods
        
        # parse facet declarations
        @facets  = args.last.kind_of?(Hash) ? args.pop : {}
        args.each { |facet| @facets[facet] = String }
        @facets = @facets.to_mash

        @facets.keys
      end

        
      module ClassMethods
        def facets
          @facets.keys
        end
        
        def facet?(property_name)
          @facets.key?(property_name)
        end
        
        def nested_facet?(property_name)
          facet?(property_name) && facet_expr(property_name).respond_to?(:each)
        end
        
        def facet_type(facet, level=nil)
          # currently sub-expression holds type of facet column (like a DataMapper declaration)
          if level.nil?
            @facets[facet]
          else
            @facets[facet][level-1] || String
          end
        end
        
        def facet_expr(facet)
          # not currently used: once Data Mapper supports this, should yield an SQL sub-expression that defines a SELECT/JOIN
          # from the entity record to the facet column.  this expression could be used 1) to simulate faceted indexing using an
          # SQL GROUP for small data-sets; or 2) to automatically generate the facet indexing expressions that go in crontab -
          # this would allow us to abstract out all SQL from the user and use DataMapper migrations to establish facet indices
          @facets[facet]
        end
      end

      module InstanceMethods
      end
    end
  end
end
