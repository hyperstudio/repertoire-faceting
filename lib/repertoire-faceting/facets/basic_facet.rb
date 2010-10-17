module Repertoire
  module Faceting
    module BasicFacet
      extend ActiveSupport::Concern
      
      include AbstractFacet
      
      Repertoire::Faceting::Model::FACET_IMPLEMENTATIONS << self
  
      def self.claim?(relation, opts={})
        relation.group_values.size == 1
      end
      
      def drill(state, combine)
        state = state.map { |v| connection.quote(v) }
        
        rel = only(:where, :joins, :group)
        rel = rel.except(:group)                                     if combine
        rel = rel.where("#{facet_column} IN (#{state.join(', ')})")  unless state.empty?
        if combine
          rel.project('signature(_packed_id)')
        else
          rel.project("#{facet_column} AS #{facet_name_value}", 'signature(_packed_id)')
        end
      end
      
      def index
        drill([], false)
      end
      
      def drill_indexed(state, combine)
        rel = Arel::Table.new(facet_index_table)
        rel = rel.where(rel[facet_name_value].in(state))            unless state.empty?
        if combine
          rel.project('collect(signature) AS signature')
        else
          rel.project(rel[facet_name_value], 'signature')
        end
      end
      
    end
  end
end