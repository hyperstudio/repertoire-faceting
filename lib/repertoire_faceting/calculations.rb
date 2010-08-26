require 'active_record/relation'
require 'pp'

module Repertoire
  module Faceting
    module Calculations
      extend ActiveSupport::Concern
      
      attr_accessor :facet_name_value
      attr_writer :nested
      
      ActiveRecord::Relation::SINGLE_VALUE_METHODS << :facet_name

      def count
        # TODO. best place to short circuit end of grouping for nested facets?
        
        if nested? && group_values.empty?
          []
        elsif facet_name_value.blank?
          super
        else
          # generate the arel and do the count
          group_field     = @group_values.first
          group_alias     = facet_name_value.to_s
          group_column    = column_for(group_field)
          aggregate_alias = 'count'

          puts "FOOWEIRD: #{group_values.join(',')}" if group_field.blank?

          select_statement = "COUNT(*) AS #{aggregate_alias}, #{group_field} AS #{group_alias}"
          relation = except(:group).select(select_statement).group(group_field)
          
          calculated_data = @klass.connection.select_all(relation.to_sql)
          
          calculated_data.inject(ActiveSupport::OrderedHash.new) do |all, row|
            key   = type_cast_calculated_value(row[group_alias], group_column)
            value = row[aggregate_alias]
            all[key] = type_cast_calculated_value(value, column_for(nil), 'count')
            all
          end
        end
      end

      def refine(opts)
        case opts
        when Array
          refine_facet(opts)
        when Hash
          refine_context(opts)
        end
      end
      
      def minimum(n)
        having("count(*) > #{n}")
      end
      
      def nils(val)
        where("#{facet_name_value} IS NOT NULL")
      end

      def nested?
        @nested ||= group_values.size > 1 
      end
      
      protected
      
      def refine_facet(*values)
        copy = clone
        raise "Not a facet" unless copy.facet_name_value
        
        # adjust grouping and record column for select
        nest_level = copy.nested? ? values.size : 1
        
        col = copy.group_values[nest_level-1]
        copy.group_values = copy.group_values[nest_level..-1]
        
        raise "No column to refine on" unless col

        # select according to facet refinement
        # TODO.  Using string interpolation b/c otherwise rails adds the wrong
        #        table name before col for associations... any better solution?
        copy = copy.where("#{col} IN (?)", Array.wrap(values))
        
        # if completely refined remove any facet count ordering
        copy.order_values = [] if copy.group_values.empty?
        
        copy
      end
      
      def refine_context(opts)
        rels = opts.map do |facet, values|
          klass.facet_for(facet).refine_facet(*values)
        end
        rels.inject(clone) do |copy, rel|
          # TODO.  VERY MESSY - clean up the merge behavior for facet_name_value, group, and nested?
          #        the grouping changes happen on facet relation, but should be recorded on central relation
          copy = copy & rel.except(:group, :order)
          copy.tap do |r|
            r.facet_name_value = facet_name_value
            if rel.nested? && facet_name_value == rel.facet_name_value
              r.group_values = rel.group_values 
              r.nested = rel.nested?
            end
           end
        end
      end

      def extensions_available?
        # TODO.  raise error if postgresql extensions not installed
      end
    end
  end
end
