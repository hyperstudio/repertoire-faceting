module Repertoire
  module Faceting
    module NestedFacet
      extend ActiveSupport::Concern
      
      include AbstractFacet
      
      Repertoire::Faceting::Model::FACET_IMPLEMENTATIONS << self
      
      def self.claim?(relation, opts={})
        relation.group_values.size > 1
      end
      
      def drill(state, combine)
        rel   = only(:where, :joins)
        cols  = group_values.map { |name| facet_column(name) }
        level = state.size
        bind  = (level > 0) ? cols[0..level-1].zip(state) : []
        
        col = cols[level]
        rel = rel.where('1=2')          if col.nil?

        bind.each do |name, value|
          value = connection.quote(value)
          rel = rel.where("#{name} = #{value}")
        end
        
        if combine
          rel.project('signature(_packed_id)')
        else
          col ||= "NULL::TEXT"
          rel.group(cols[0..level]).project("#{col} AS #{facet_name_value}", 'signature(_packed_id)')
        end
      end
      
      def index
        cols = group_values.map { |name| facet_column(name) }
        rel  = only(:where, :joins, :group)
        
        rel.project(cols, 'signature(_packed_id)')
      end
      
      def drill_indexed(state, combine)
        rel = Arel::Table.new(facet_index_table)
        
        bind = group_values[0..state.size-1].zip(state)
        bind.map do |col, val|
          rel = rel.where(rel[col].eq(val))
        end
        
        query_col = group_values[state.size] || 'NULL'
        if combine
          rel.group(query_col).project('collect(signature) AS signature')
        else  
          rel.project("#{query_col} AS #{facet_name_value}", 'signature')
        end
      end
      
    end
  end
end