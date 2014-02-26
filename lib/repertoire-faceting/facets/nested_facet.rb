module Repertoire
  module Faceting
    module Facets

      # Implementation of AbstractFacet for facets whose values fall into a nested taxonomy.
      # By default, all facets that group several columns will follow this behavior.
      #
      # See Repertoire::Faceting::Model::ClassMethods for usage.
      #
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
          rel.select("facet.signature(#{table_name}.#{faceting_id})").arel
        end

        def drill(state)
          return read_index(state, false) if indexed?
          rel = only(:where, :joins)
          grp = bind_nest(group_values, state) do |expr, val|
            rel = rel.where("#{expr} = #{connection.quote(val)}")
          end
          rel.group(grp).select(["#{grp.last} AS #{facet_name}", "facet.signature(#{table_name}.#{faceting_id})"]).arel
        end

        def create_index(faceting_id)
          levels = group_values.length

          # Construct expressions at each grouping level, right pad with nil
          expr_drills = (0..levels-1).map do |i|
            group_values[0..i] + (i+1..levels-1).collect { "NULL" }
          end

          # Construct indexes for each drill level
          queries = []
          expr_drills.each_with_index do |exprs, level|
            rel = only(:where, :joins)
            exprs.zip(columns).each do |expr, col|
              rel = rel.select("#{expr} AS #{col}")
            end
            rel = rel.group(columns[0..level])

            queries << rel.select(["#{level+1} AS level", "facet.signature(#{table_name}.#{faceting_id})"]).to_sql
          end

          # Root of tree
          empty_cols = columns.map { |col| "NULL AS #{col}"}
          queries << only(:where).select(empty_cols + ["0 AS level", "facet.signature(#{table_name}.#{faceting_id})"]).to_sql

          # Give the fullest index first (i.e. leaves of the tree), so the database
          # can resolve types before encountering any NULL values (i.e. values of
          # indeterminate type)
          queries = queries.reverse

          # The full index table is union of indices at each drill level
          sql = queries.join(" UNION ")

          connection.create_materialized_view(facet_index_table, sql)
        end

        def drop_index
          connection.drop_materialized_view(facet_index_table)
        end

        def refresh_index
          connection.refresh_materialized_view(facet_index_table)
        end

        private

        def columns
          (1..group_values.size).map { |i| "#{facet_name}_#{i}"}
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