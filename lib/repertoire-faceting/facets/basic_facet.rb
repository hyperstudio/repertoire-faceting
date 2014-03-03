module Repertoire #:nodoc:
  module Faceting #:nodoc:
    module Facets #:nodoc:

      # Implementation of AbstractFacet for non-nested, single-valued facets.  By default,
      # all facets that have a single group column will follow this behavior.
      #
      # See Repertoire::Faceting::Model::ClassMethods for usage.
      #
      module BasicFacet
        include AbstractFacet
        include Arel

        def self.claim?(relation)
          relation.group_values.size == 1
        end

        def signature(state)
          return read_index(state, true)             if facet_indexed?
          col = group_values.first
          rel = only(:where, :joins)
          rel = rel.where(in_clause(col, state))     unless state.empty?
          rel.select("facet.signature(#{table_name}.#{faceting_id})").arel
        end

        def drill(state)
          return read_index(state, false)            if facet_indexed?
          col = group_values.first
          rel = only(:where, :joins, :group)
          rel = rel.where(in_clause(col, state))     unless state.empty?
          rel.select(["#{col} AS #{facet_name}", "facet.signature(#{table_name}.#{faceting_id})"]).arel
        end

        def create_index
          col = group_values.first
          rel = only(:where, :joins, :group)
          sql = rel.select(["#{col} AS #{facet_name}", "facet.signature(#{table_name}.#{faceting_id})"]).to_sql

          connection.create_materialized_view(facet_index_name, sql)
        end

        private

        def in_clause(col, values)
          # ActiveRecord unhelpfully scatters wrong table names in predicates...
          values = values.map { |v| connection.quote(v) }
          "#{col} IN (#{values.join(', ')})"
        end

        def read_index(state, aggregate)
          index = Arel::Table.new(facet_index_name)
          rel   = SelectManager.new Table.engine

          rel.from index
          rel.where(index[facet_name].in(state)) unless state.empty?

          if aggregate
            rel.project('facet.collect(signature) AS signature')
          else
            rel.project(index[facet_name], index[:signature])
          end
        end

      end
    end
  end
end