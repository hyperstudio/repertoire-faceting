module Repertoire
  module Faceting
    module Relation
      module QueryMethods
        extend ActiveSupport::Concern

        # N.B. These methods augment those defined in active_record/relation/query_methods
      
        attr_accessor :refine_value, :nils_value, :minimum_value
      
        [:refine, :nils, :minimum].each do |attr|
          ActiveRecord::Relation::SINGLE_VALUE_METHODS << attr
        end

        #
        # Methods for managing refinements hash
        #

        def refine(opts)
          clone.tap { |r| r.refine_value = merge_hashes(r.refine_value, opts) }
        end

        def minimum(count)
          clone.tap { |f| f.minimum_value = count }
        end

        def nils(value=true)
          clone.tap { |f| f.nils_value = value }
        end

        def reorder(*args)
          clone.tap { |f| f.order_values = args.flatten }
        end

        def refine_value
          @refine_value ||= {}
        end
        
        def refined_facets?
          !refine_value.empty?
        end
        
      end
    end
  end
end
