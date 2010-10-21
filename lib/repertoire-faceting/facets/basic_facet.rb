module Repertoire
  module Faceting
    module Facets
      module BasicFacet
        include AbstractFacet
        include Arel
      
        #
        # Registration
        #
      
        def self.claim?(relation)
          relation.group_values.size == 1
        end

        #
        # Non-indexed queries (in ActiveRecord)
        #
      
        def signature(state, combine)
          return signature_indexed(state, combine) if indexed?
          
          col = group_values.first
          
          rel = only(:where, :joins, :group)
          rel = rel.except(:group)                   if combine
          rel = rel.where(in_clause(col, state))     unless state.empty?
        
          if combine
            rel.select('signature(_packed_id)').arel
          else
            rel.select(["#{col} AS #{facet_name}", 'signature(_packed_id)']).arel
          end
        end
        
        def in_clause(col, values)
          # ActiveRecord unhelpfully scatters wrong table names in predicates...
          values = values.map { |v| connection.quote(v) }
          "#{col} IN (#{values.join(', ')})"
        end
      
        def index
          col = group_values.first
          only(:where, :joins, :group).select(["#{col} AS #{facet_name}", 'signature(_packed_id)']).arel
        end

        #
        # Index queries (in Arel)
        #
      
        def signature_indexed(state, combine)
          index = Arel::Table.new(facet_index_table)
          rel   = SelectManager.new Table.engine
          
          rel.from index
          rel.where(index[facet_name].in(state))     unless state.empty?
        
          if combine
            rel.project('collect(signature) AS signature')
          else
            rel.project(index[facet_name], index[:signature])
          end
        end
      
      end
    end
  end
end