module Repertoire
  module Faceting
    module Relation
      module QueryMethods
        extend ActiveSupport::Concern

        # N.B. These methods augment those defined in active_record/relation/query_methods
      
        attr_accessor :facet_name_value, :refine_value, :minimum_value, :nils_value
      
        [:facet_name, :refine, :minimum, :nils].each do |meth|
          ActiveRecord::Relation::SINGLE_VALUE_METHODS << meth
        end

        def refine(opts)
          clone.tap { |r| r.refine_value = merge_hashes(r.refine_value, opts) }
        end
      
        def minimum(n)
          clone.tap { |r| r.minimum_value = n }
        end
      
        def nils(val)
          clone.tap { |r| r.nils_value = val }
        end

        def refine_value
          @refine_value ||= {}
        end
        
        def refined_facets?
          !refine_value.empty?
        end

        def clear_facet_options
          relation = clone
          relation.facet_name_value = nil
          relation.refine_value     = nil
          relation.minimum_value    = nil
          relation.nils_value       = nil
          relation
        end

        def forbid_facet_options
          raise "Facet refinements used but attribute not a facet" unless refine_value.empty?
          raise "Minimum set but attribute not a facet"            unless minimum_value.nil?
          raise "Nils option set but attribute not a facet"        unless nils_value.nil?
        end

        def facet?
          !facet_name_value.nil?
        end

        def indexed_facet?
          facet? && @klass.indexed_facet?(facet_name_value)
        end

        def facet(name)
          name = name.to_sym
          raise "Unknown facet #{name}" unless @klass.facet?(name)
                
          @klass.facets[name].call
        end
        
      end
    end
  end
end