module Repertoire
  module Faceting
    module Model
      extend ActiveSupport::Concern
      
      included do |base|
        base.singleton_class.delegate :refine, :minimum, :nils, :signature, :to => :scoped
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
            scoped.only(:joins, :includes, :refine).merge(relation)
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
          indexed_facets.include?(name)
        end

        protected

        def valid_facet_name?(name)
          if !facets[name] && respond_to?(name, true)
            logger.warn "Creating facet :#{name}. " \
                        "Overwriting existing method #{self.name}.#{name}."
          end
        end
      end
    end
  end
end