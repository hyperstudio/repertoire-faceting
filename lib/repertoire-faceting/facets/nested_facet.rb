module Repertoire
  module Faceting
    module Facets
      module NestedFacet
        include AbstractFacet
        include Arel
      
        #
        # Registration
        #
      
        def self.claim?(relation)
          relation.group_values.size > 1
        end
      
        #
        # Non-indexed queries (in ActiveRecord)
        #
      
        def signature(state, combine)
          return signature_indexed(state, combine) if indexed?

          nlevel, ncol, grp, bind = parse(state)
          rel                     = only(:where, :joins)
          
          # rel.where(ncol => state) preferable, but ActiveRecord adds wrong table name for joins
          bind.each do |col, value|
            value = connection.quote(value)
            rel = rel.where("#{col} = #{value}")
          end
        
          if combine
            rel.select('signature(_packed_id)').arel
          else
            ncol ||= "NULL::TEXT"
            rel.group(grp).select(["#{ncol} AS #{facet_name}", 'signature(_packed_id)']).arel
          end
        end
      
        def index
          rel  = only(:where, :joins, :group)
          cols = group_values.map(&:to_s)
          rel.select(cols).select('signature(_packed_id)').arel
        end
        
        #
        # Index queries (in Arel)
        #
      
        def signature_indexed(state, combine)
          nlevel, ncol, grp, bind = parse(state)
          index                   = Table.new(facet_index_table)
          
          rel = SelectManager.new Table.engine
          rel.from index
          
          bind.map do |col, val|
            rel = rel.where(index[col].eq(val))
          end

          if combine
            rel.group(ncol).project('collect(signature) AS signature')
          else
            # rel[ncol].as(facet_name) preferable, but arel 2.0 has no provision for column aliases
            rel.project("#{ncol} AS #{facet_name}", index[:signature])
          end
        end
        
        private
        
        def parse(state)
          nlevel = state.size
          ncol   = group_values[nlevel]
          
          grp    = group_values[0..nlevel].map(&:to_s)
          bind   = (nlevel > 0) ? grp[0..nlevel-1].zip(state) : []
          
          [nlevel, ncol, grp, bind]
        end
      
      end
    end
  end
end