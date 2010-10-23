module Repertoire
  module Faceting
    module Facets
      module NestedFacet
        include AbstractFacet
        include Arel
      
        def self.claim?(relation)
          relation.group_values.size > 1
        end
      
        def signature(state)
          return read_index(state, true) if indexed?
          rel = only(:where, :joins) 
          bind_nest(state, group_values) do |expr, val|
            rel = rel.where("#{expr} = #{connection.quote(val)}") if expr && val
          end
          rel.select('signature(_packed_id)').arel
        end
        
        def drill(state)
          return read_index(state, false) if indexed?
          rel = only(:where, :joins)
          grp, proj = bind_nest(state, group_values) do |expr, val|
            rel = rel.where("#{expr} = #{connection.quote(val)}") if expr && val
          end
          rel.group(grp).select(["#{proj} AS #{facet_name}", 'signature(_packed_id)']).arel
        end
      
        def create_index
          rel = only(:where, :joins, :group)
          group_values.zip(columns).each do |expr, col|
            rel = rel.select("#{expr} AS #{col}")
          end
          sql = rel.select('signature(_packed_id)').to_sql
          
          connection.recreate_table(facet_index_table, sql)
          connection.expand_nesting(facet_index_table)
        end
        
        private

        def columns
          (1..group_values.size).map { |i| "#{facet_name}#{i}"}
        end
        
        def bind_nest(state, cols, &block)
          level = state.size
          grp   = cols[0..level].map(&:to_s)
          bind  = grp.zip(state)
#          bind  = (level > 0) ? grp[0..level-1].zip(state) : []
          bind.each { |col, val| yield(col, val) }
          proj  = (level < cols.size) ? grp.last : "NULL::TEXT"
          
          [ grp, proj ]
        end
      
        def read_index(state, aggregate)
          index = Table.new(facet_index_table)
          rel   = SelectManager.new Table.engine
          
          rel.from index
          grp, proj = bind_nest(state, columns) do |col, val|
            rel.where(index[col].eq(val))
          end

          if aggregate
            rel.project('signature AS signature')
          else
            # arel 2.0 has no documented way to alias a column...
            rel.project("#{proj} AS #{facet_name}", index[:signature])
          end
        end
      
      end
    end
  end
end