module Repertoire
  module Faceting
    # Include this module in your model before declaring any facets.
    module Model
      extend ActiveSupport::Concern
      
      included do |base|
        base.singleton_class.delegate :refine, :minimum, :nils, :reorder, :to_sql, :to => :scoped
      end
      
      module ClassMethods
        
        def facets
          read_inheritable_attribute(:facets) || write_inheritable_attribute(:facets, {})
        end
        
        def facet?(name)
          facets.key?(name.to_sym)
        end
        
        def facet_names
          facets.keys
        end
        
        # Drops any unused facet indices, updates its packed ids, then recreates indices 
        # for the facets with the provided names.  If no names are provided, then the existing 
        # facet indices are refreshed.
        def update_indexed_facets(*facet_names)
          facet_names.flatten!
          
          # drop old facet indices
          indexed_facets = connection.indexed_facets(table_name)
          indexed_facets.each do |name|
            table = connection.facet_table_name(table_name, name)
            connection.drop_table(table)
          end

          # update the model packed id
          connection.renumber_table(table_name)

          # re-create the facet indices
          connection.transaction do
            (facet_names || indexed_facets).each do |name|
              raise "Unknown facet #{name}" unless facet?(name)
              facets[name].create_index
            end
          end
          
          # return the successfully created facets
          connection.indexed_facets(table_name)
        end
        
        protected
        def facet(name, rel=nil)
          name = name.to_sym

          # default: group by column with facet name, order by count descending
          rel ||= scoped
          rel = rel.group(name)                           if rel.group_values.empty?
          rel = rel.order(["count DESC", "#{name} ASC"])  if rel.order_values.empty?

          # locate facet implementation that can handle relation
          facets[name] = Facets::AbstractFacet.mixin(name, rel)
        end
      end
      
    end
  end
end