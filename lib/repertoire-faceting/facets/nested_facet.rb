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
          bind_nest(group_values, state) do |expr, val|
            rel = rel.where("#{expr} = #{connection.quote(val)}")
          end
          rel.select('signature(_packed_id)').arel
        end
        
        def drill(state)
          return read_index(state, false) if indexed?
          rel = only(:where, :joins)
          grp = bind_nest(group_values, state) do |expr, val|
            rel = rel.where("#{expr} = #{connection.quote(val)}")
          end
          rel.group(grp).select(["#{grp.last} AS #{facet_name}", 'signature(_packed_id)']).arel
        end
      
        def create_index
          rel = only(:where, :joins, :group)
          group_values.zip(columns).each do |expr, col|
            rel = rel.select("#{expr} AS #{col}")
          end
          sql = rel.select(["#{group_values.size} AS level", 'signature(_packed_id)']).to_sql
          
          connection.recreate_table(facet_index_table, sql)
          connection.expand_nesting(facet_index_table)
        end
        
        private

        def columns
          (1..group_values.size).map { |i| "#{facet_name}#{i}"}
        end
        
        # Iterates over all the columns that have state in turn, and returns
        # a grouping of the columns one level further nested
        def bind_nest(cols, state, &block)
          level = state.size
          grp   = cols[0..level]                      # advance one nest step
                    
          if level > 0
            cols[0..level-1].zip(state).each do |col, val| 
              yield(col, val)
            end
          end
          grp << "NULL::TEXT" if level >= cols.size
          
          grp
        end
      
        def read_index(state, aggregate)
          index = Table.new(facet_index_table)
          rel   = SelectManager.new Table.engine
          
          rel.from index
          grp = bind_nest(columns, state) do |col, val|
            rel.where(index[col].eq(val))
          end

          if aggregate
            rel.where(index[:level].eq(state.size))
            rel.project('signature AS signature')
          else
            rel.where(index[:level].eq(grp.size)) if grp.size <= group_values.size
            # arel 2.0 has no documented way to alias a column...
            rel.project("#{grp.last} AS #{facet_name}", index[:signature])
          end
        end
      
      end
    end
  end
end