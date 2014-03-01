module Repertoire
  module Faceting
    module Relation  # :nodoc: all
      module QueryMethods
        extend ActiveSupport::Concern

        # N.B. These methods augment those defined in active_record/relation/query_methods
      
        attr_accessor :refine_value, :nils_value, :minimum_value
      
        [:refine, :nils, :minimum].each do |attr|
          ActiveRecord::Relation::SINGLE_VALUE_METHODS << attr
        end

        def refine_value
          @refine_value ||= {}
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

        def nils(include_nils=true)
          clone.tap { |f| f.nils_value = (if include_nils then :include else :exclude end) }
        end

        def reorder(*args)
          clone.tap { |f| f.order_values = args.flatten }
        end

        def refined_facets?
          !refine_value.empty?
        end

        private

        def merge_hashes(h1={}, h2={})
          h2.inject(h1.clone) do |hsh, (key, values)|
            key    = key.to_sym
            values = [values].flatten
            hsh[key] ||= []
            hsh[key] |= values
            hsh
          end
        end

      end
    end
  end
end
