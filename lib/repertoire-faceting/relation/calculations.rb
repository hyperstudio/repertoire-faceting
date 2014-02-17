module Repertoire
  module Faceting
    module Relation  # :nodoc: all
      module Calculations
     
        # Over-rides count() in ActiveRecord::Relation::Calculations
        
        # Construct and execute a count over the specified facet.
        def count(name = nil, options = {})
          if name.present? && @klass.facet?(name)
            name       = name.to_sym
            parent     = @klass.facets[name]
            facet      = parent.merge(self)
            state      = refine_value[name] || []
            signatures = facet.drill(state)

            # See ActiveRecord::Relation::HashMerger
            facet.minimum_value = self.minimum_value || parent.minimum_value
            facet.nils_value    = self.nils_value    || parent.nils_value

            connection.population(facet, masks, signatures)
          else
            super
          end
        end

        protected
        
        # Over-rides build_arel() in ActiveRecord::Relation
        def build_arel
          if refined_facets?
            join_sql = connection.mask_members_sql(masks, table_name, faceting_id)
            except(:refine).joins(join_sql).arel
          else
            super
          end
        end
        
        # Returns an array of arel expressions over the model table, one for the base query
        # (as identified in the where and join clauses), and one for each participating facet
        # (identified in the refine clause).  A bitwise and of all these values will can be
        # used to compute the set of base records for the result records at this point in the
        # faceted search.
        def masks
          base = except(:order, :limit, :offset)
          masks = []
          
          masks << base.only(:where, :join).select("signature(#{table_name}.#{faceting_id})").arel  if base.where_values.present?
          refine_value.each do |name, values|
            raise QueryError, "Unkown facet #{name} on #{klass.name}"                 unless @klass.facet?(name)
            masks << @klass.facets[name].signature(values)
          end
          
          masks
        end
        
      end
    end
  end
end