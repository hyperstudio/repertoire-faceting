require 'active_support/core_ext/object/blank'

module Repertoire
  module Faceting
    module Facets
      module AbstractFacet
        
        attr_accessor :facet_name
      
        # Abstract interface that all facet implementations should fill in
        # At minimum, define self.claim?, signature, and drill to create working facets.
      
        # Return true if this implementation can index this facet      
        def self.claim?(relation)
          raise 'Please implement claim? for your facet'
        end
              
        # Return an arel expression for the signature of all models matching the given current refinement state for
        # this facet (and ignoring all others).
        def signature(state)
          raise 'Please implement signature for your facet'
        end
        
        # Return an arel expression for state, signature pairs from which one can refine the current state of this facet
        # (ignoring all others)
        def drill(state)
          raise 'Please implement drill for your facet'
        end

        # Return an arel expression for this facet's index table, or raise an exception if indexing not supported
        def index
          raise 'This facet does not support indexing'
        end
        
        # Helper methods available to your facet implementation
        
        # Return the facet's index table name
        def facet_index_table
          connection.facet_table_name(table_name, facet_name).to_sym
        end

        def indexed?
          connection.indexed_facets(table_name).map(&:to_sym).include?(facet_name)
        end

        #      
        # Track facet implementations so they can register to claim facets on model entities
        #

        def self.implementations
          @@implementations ||= []
        end

        def self.included(klass)
          implementations << klass
        end

        def self.mixin(name, relation)
          impls = implementations.select { |mixin| mixin.claim?(relation) }

          raise QueryError, "No available facet implementations for #{name}"                           if impls.size < 1
          relation.logger.warn "Multiple facet implementations claimed #{name}. Using #{impls.last}"   if impls.size > 1

          # mix in facet implementation and configure
          relation.singleton_class.send(:include, impls.last)
          relation.facet_name = name
          
          relation
        end
      
      end
    end
  end
end