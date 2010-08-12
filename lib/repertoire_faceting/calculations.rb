require 'active_record/relation'

module Repertoire
  module Faceting
    module Calculations
      extend ActiveSupport::Concern
      
      attr_accessor :facet_name

      def count
        # TODO. best place to short circuit end of grouping for nested facets?
        if nested? && group_values.empty?
          []
        else
          super
        end
      end

      def refine(opts)
        rel = clone
        
        refinements = []
        opts.each do |facet, values|
          values    = [values].flatten
          facet_rel = klass.facet_for(facet)
          refinements << facet_rel.facet_expr(values).to_sql
          # adjust grouping if counting a nested facet
          if (rel.nested? && facet == self.facet_name)
            rel.group_values = rel.group_values[values.size..-1]
          end
        end
      
        if refinements.empty?
          rel
        else
          refinements = refinements.map { |s| "(#{s})"}
          rel.where("contains(#{ refinements.join(' & ') }, #{table_name}.id)")
        end
      end
      
      def facet_expr(values)
        # TODO. return an indexed version when available
        rel = clone.select("signature(#{table_name}.id)")
        
        if rel.nested?
          values.each_with_index do |v, i|
            col = facet_column(i)
            rel = rel.where("#{col} = ?", v)
          end
        else
          col = facet_column(values.size-1)
          rel = rel.where("#{col} IN (?)", values)
        end

        # TODO. acceptable way to remove clauses from a query?
        rel.order_values = []
        rel.group_values = []
        
        rel
      end
      
      def facet_index_expr(facet)
        rel = facet_for(facet).reorder(nil)
        rel.select(facet, "signature(#{table_name}.id)")
      end

      def minimum(n)
        having("count(*) > #{n}")
      end

      def logic(type)
        raise "Unknown logic: #{type}" unless [:and, :or, :nested, :geom].include?(type)
        clone.tap { |r| r.logic_value = type }
      end
      
      def nils(val)
        where("#{facet_name} IS NOT NULL")
      end
      
      def signature
        extensions_available?
        select("signature(#{table_name}.id)")
      end
      
      def facet_column(nest=0)
        group_values[nest] || group_values.last
      end

      def nested?
        @nested ||= group_values.size > 1 
      end
      
      protected

      def extensions_available?
        # TODO.  raise error if postgresql extensions not installed
      end
    end
  end
end
