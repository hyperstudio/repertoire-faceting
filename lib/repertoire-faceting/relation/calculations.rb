module Repertoire
  module Faceting
    module Relation
      module Calculations
        extend ActiveSupport::Concern

        # N.B. These methods over-ride/extend those defined in active_record/relation/calculations        

        def count(name = nil, options = {})
          if name.present? && facet?(name)
            name       = name.to_sym
            facet      = @klass.facets[name].merge(self)
            state      = refine_value[name] || []
            signatures = facet.drill(state)
            connection.population(facet, masks, signatures)
          else
            super
          end
        end
        
        def build_arel
          if refined_facets?
            join_sql = connection.mask_members_sql(masks)
            except(:refine).joins(join_sql).arel
          else
            super
          end
        end
        
        def masks
          base = except(:order, :limit, :offset)
          masks = []
          
          refine_value.each do |name, values|
            raise QueryError, "Unkown facet #{name} on #{klass.name}"             unless @klass.facet?(name)
            masks << @klass.facets[name].signature(values)
          end
          masks << base.only(:where, :join).select('signature(_packed_id)').arel  if base.where_values.present?
          masks << @klass.scoped.select('signature(_packed_id)').arel             if masks.empty?
          
          masks
        end
        
      end
    end
  end
end