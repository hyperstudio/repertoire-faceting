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
        
        def masks
          masks = []
          
          refine_value.each do |name, values|
            masks << facet(name).facet_drill(values, true)
          end
          masks << only(:where, :joins).project('signature(_packed_id)') if where_values.present?
          masks << @klass.scoped.project('signature(_packed_id)')        if masks.empty?
          
          masks
        end

        protected
        
        def facet_drill(values, combine)
          indexed_facet? ? drill_indexed(values, combine) : drill(values, combine)
        end

        def facet_count
          state      = refine_value[facet_name_value] || []
          signatures = facet_drill(state, false)
          
          connection.population(self, masks, signatures)
        end
        
        def facet_result
          join_sql = connection.mask_members_sql(masks)
          clear_facet_options.joins(join_sql).build_arel
        end
        
      end
    end
  end
end