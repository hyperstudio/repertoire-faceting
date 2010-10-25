module Repertoire
  module Faceting
    module Relation  # :nodoc: all
      module SpawnMethods

        # N. B. These methods over-ride/extend those defined in active_record/relation/calculations
      
        def merge(r1)
          super.tap { |r2| r2.refine_value = merge_hashes(self.refine_value, r1.refine_value) }
        end
      
        protected
      
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