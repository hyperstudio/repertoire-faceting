require 'active_support/core_ext/object/blank'

module Repertoire
  module Faceting
    module Facets #:nodoc:

      # Abstract interface all facet implementations must fulfil.  At minimum, implementors should
      # define self.claim?(), signature(), and drill() to create a new kind of facet.
      #
      # For indexing support, implement create_index to create your index table, detect its presence
      # in signature() and drill(), and act accordingly.
      #
      # N.B. Facet instances can assume they have been mixed in with an ActiveRecord scoped relation
      #      that defines the relational dataset of which they identify an attribute. Consequently,
      #      they have access to relevant fields: table_name, faceting_id, and indexed_facets, among
      #      others.
      #
      #      Facet definitions should not access the database connection. Rather, they provide arel
      #      expressions which Repertoire::Faceting::Relation mixins use to access the connection.
      #
      # See BasicFacet and NestedFacet for examples of facet implementations.
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

        # Return an arel expression for (state, signature) pairs from which one can refine the current state of this facet
        # (ignoring all others)
        def drill(state)
          raise 'Please implement drill for your facet'
        end

        # Return an arel expression describing this facet's index table, or raise an exception if indexing not supported
        #
        # Implementations should build signatures using the faceting_id column passed in, which may not exist yet on the
        # model table itself.
        def create_index(faceting_id)
          raise 'Facet #{facet_name} does not support indexing'
        end
        
        def refresh_index
          raise 'Facet #{facet_name} indexes cannot be refreshed'
        end
        
        def drop_index
          raise 'Facet #{facet_name} indexes cannot be dropped'
        end

        # Returns true if the facet's index table exists
        def indexed?
          connection.indexed_facets(table_name).map(&:to_sym).include?(facet_name)
        end

        protected

        # Return the facet's index table name
        def facet_index_table
          connection.facet_table_name(table_name, facet_name).to_sym
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