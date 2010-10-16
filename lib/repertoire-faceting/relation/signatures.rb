module Repertoire
  module Faceting
    module Relation
      module Signatures
        extend ActiveSupport::Concern
      
        # return an arel expression for (potentially grouped or refined) signature
        # if refined, will use facet indices when available
        def signature(values=nil)
          if !facet?
            base_signature
          elsif indexed_facet?
            indexed_signature(values)
          else
            unindexed_signature(values)
          end
        end

        protected

        def base_signature
          except(:order, :limit, :offset).project('signature(_packed_id)')
        end

        def indexed_signature(values)
          index = Arel::Table.new(facet_index_table)
          if values.nil?
            index.project(index[facet_name_value], 'signature')
          elsif nested_facet?
            bindings = group_values[0..values.size-1].zip(values)
            bindings.map do |col, val|
              index = index.where(index[col].eq(val))
            end
            query_column = group_values[values.size] || 'NULL'
            index.group(query_column).project("#{query_column} AS #{facet_name_value}", 'collect(signature) AS signature')
          else
            index.where(index[facet_name_value].in(values)).project('collect(signature) AS signature')
          end
        end
      
        def unindexed_signature(values)
          relation = except(:group, :order, :limit, :offset)
          cols     = group_values.map { |name| facet_column(name) }
          expr     = facet_value_expr(values)
          
          # TODO foul hack at the end of a nesting drill-down
          if expr.nil?
            relation = relation.where('1=2')
            expr = cols.last
          end

          if values.nil?
            relation = relation.group(cols)
          elsif nested_facet?
            level    = values.size
            pairs    = (level > 0) ? cols[0..level-1].zip(values) : []
            relation = relation.group(cols[0..level]).where(Hash[pairs])
          else
            relation = relation.where(expr => values)
          end
        
          if nested_facet? && !values.nil?
            relation.project("#{expr} AS #{facet_name_value}", 'signature(_packed_id)')
          elsif relation.group_values.present?
            relation.project(expr, 'signature(_packed_id)')
          else
            relation.project('signature(_packed_id)')
          end
        end
      
        private
      
        def facet_column(name)
          name.to_s.include?('.') ? name : "#{joins_values.last || table_name}.#{name}"
        end
      
        def facet_value_expr(values)
          cols = group_values.map { |name| facet_column(name) }
          if cols.size == 1
            cols.first
          elsif values.nil?
            cols.join(', ')
          else
            cols[values.size]
          end
        end
      
        def facet_index_table
          connection.facet_table_name(@klass.table_name, facet_name_value)
        end
      end
    end
  end
end