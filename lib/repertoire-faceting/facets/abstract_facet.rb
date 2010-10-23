require 'active_support/core_ext/object/blank'

module Repertoire
  module Faceting
    module Facets
      
      # Abstract interface all facet implementations must fulfil.  At minimum, define self.claim?,
      # signature and drill to create a working facet.
      module AbstractFacet
        
        attr_accessor :facet_name
      
        # Return true if this facet implementation can index this ActiveRecord relation.  If multiple
        # implementations claim a facet, the one that is laoded last wins.  
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

        # Return an arel expression describing this facet's index table, or raise an exception if indexing not supported
        def create_index
          raise 'Facet #{facet_name} does not support indexing'
        end
        
        protected
        
        # Return the facet's index table name
        def facet_index_table
          connection.facet_table_name(table_name, facet_name).to_sym
        end

        # Returns true if the facet's index table exists
        def indexed?
          connection.indexed_facets(table_name).map(&:to_sym).include?(facet_name)
        end

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