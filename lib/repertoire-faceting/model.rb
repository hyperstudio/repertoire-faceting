module Repertoire
  module Faceting
    module Model
      extend ActiveSupport::Concern
      
      FACET_IMPLEMENTATIONS = []
      
      included do |base|
        base.singleton_class.delegate :refine, :minimum, :nils, :to => :scoped
      end
      
      module ClassMethods
        def facet(name, options=nil)
          name = name.to_sym
          valid_facet_name?(name)
          
          facets[name] = lambda do |*args|
            relation = options || scoped
            
            raise QueryError, "Already configuring facet #{relation.facet_name_value}" if relation.facet_name_value.present?
            
            # default: group by attribute with facet name, order by count descending
            relation = relation.clone.tap { |r| r.facet_name_value = name }
            relation = relation.group(name)                 if relation.group_values.empty?
            relation = relation.order(["count DESC", name]) if relation.order_values.empty?
            
            # facet scopes only inherit selection info from their parent
            relation = scoped.only(:joins, :refine).merge(relation)
            
            # add appropriate faceting implementation
            relation = mixin_faceting(relation)
            
            relation
          end

          singleton_class.send(:redefine_method, name, &facets[name])
        end
        
        def facets
          read_inheritable_attribute(:facets) || write_inheritable_attribute(:facets, {})
        end
        
        def facet?(name)
          facets.key?(name.to_sym)
        end
        
        def indexed_facets
          connection.indexed_facets(table_name).map(&:to_sym)
        end

        def indexed_facet?(name)
          facet?(name) && indexed_facets.include?(name)
        end

        protected
        
        def valid_facet_name?(name)
          if !facets[name] && respond_to?(name, true)
            logger.warn "Creating facet :#{name}. " \
                        "Overwriting existing method #{self.name}.#{name}."
          end
        end
        
        def mixin_faceting(rel)
          mixins = FACET_IMPLEMENTATIONS.select { |k| k.claim?(rel) }
          raise QueryError, "Multiple facet implementations claimed #{name}. Using #{mixins.last}" if mixins.size > 1
          raise QueryError, "No available facet implementations for #{name}"                       if mixins.size < 1
          rel.singleton_class.send(:include, mixins.last)
          rel
        end
        
      end
    end
  end
end