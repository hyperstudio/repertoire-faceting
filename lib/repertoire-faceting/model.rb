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