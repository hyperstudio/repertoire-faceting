module Repertoire
  module Faceting
    module Relation
      module Calculations
        extend ActiveSupport::Concern

        # N.B. These methods over-ride/extend those defined in active_record/relation/calculations

        def count
          facet? ? facet_count : super
        end
        
        def build_arel
          refined_facets? ? facet_result : super
        end

        protected

        def facet_count
          foo = nested_facet? ? (refine_value[facet_name_value] || []) : nil
          
          base    = only(:where, :joins, :includes).signature
          filters = only(:refine, :facet_name).facet_filters
          facet   = except(:where, :refine).signature(foo)
          
          connection.population(self, base, filters, facet)
        end
        
        def facet_result
          filters = only(:refine).facet_filters
          join_sql = connection.filter_join_sql(filters)
          
          clear_facet_options.joins(join_sql).build_arel
        end
        
        def facet_filters
          filters = {}
          refine_value.each do |name, values|
            next if name == facet_name_value
            filters[name] = scoping_facet(name).signature(values)
          end
          
          filters
        end
        
      end
    end
  end
end