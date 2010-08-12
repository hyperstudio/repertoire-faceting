module Repertoire
  module Faceting
    module Model
      extend ActiveSupport::Concern
       
      included do |base|    
        base.singleton_class.delegate :refine, :minimum, :signature, :to => :scoped
      end
      
      module ClassMethods
        def facet(name, options=nil)
          name = name.to_sym
          valid_facet_name?(name)
          
          facets[name] = lambda do |*args|
            relation = if options.is_a?(Hash)
              scoped.apply_finder_options(options)
            elsif options
              scoped.merge(options)
            else
              scoped
            end
            
            # defaults: group on same column as facet name, counts descending
            relation = relation.group(name) if relation.group_values.empty?
            
            # set facet metadata on relation
            relation.facet_name = name
            
            relation
          end

          singleton_class.send(:redefine_method, name, &facets[name])
        end
        
        def facets
          read_inheritable_attribute(:facets) || write_inheritable_attribute(:facets, {})
        end
        
        def facet?(name)
          name = name.to_sym
          facets.key?(name)
        end
        
        def facet_for(name)
          name = name.to_sym
          raise "Unknown facet #{name}" unless facet?(name)
          facets[name].call
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