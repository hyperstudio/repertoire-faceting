module Repertoire
  module Faceting
    module Facets
      
      # Basic facet implementation for non-nested, single-valued facets.  By default, all facets
      # that have a single group column will follow this behavior.
      module BasicFacet
        include AbstractFacet
        include Arel
      
        def self.claim?(relation)
          relation.group_values.size == 1
        end
        
        def signature(state)
          return read_index(state, true)             if indexed?
          col = group_values.first
          rel = only(:where, :joins)
          rel = rel.where(in_clause(col, state))     unless state.empty?
          rel.select('signature(_packed_id)').arel
        end
      
        def drill(state)
          return read_index(state, false)            if indexed?
          col = group_values.first          
          rel = only(:where, :joins, :group)
          rel = rel.where(in_clause(col, state))     unless state.empty?
          rel.select(["#{col} AS #{facet_name}", 'signature(_packed_id)']).arel
        end
      
        def index
          col = group_values.first
          only(:where, :joins, :group).select(["#{col} AS #{facet_name}", 'signature(_packed_id)']).arel
        end

        private
        
        def in_clause(col, values)
          # ActiveRecord unhelpfully scatters wrong table names in predicates...
          values = values.map { |v| connection.quote(v) }
          "#{col} IN (#{values.join(', ')})"
        end
      
        def read_index(state, aggregate)
          index = Arel::Table.new(facet_index_table)
          rel   = SelectManager.new Table.engine
          
          rel.from index
          rel.where(index[facet_name].in(state)) unless state.empty?
        
          if aggregate
            rel.project('collect(signature) AS signature')
          else
            rel.project(index[facet_name], index[:signature])
          end
        end
      
      end
    end
  end
end