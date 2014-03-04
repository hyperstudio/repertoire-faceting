require 'active_support/core_ext/object/blank'

module Repertoire
  module Faceting
    module Facets #:nodoc:

      # Abstract interface all facet implementations must fulfil.  At minimum, implementors should
      # define self.claim?(), signature(), and drill() to create a new kind of facet.
      #
      # For indexing support, implement create_index(), refresh_index(), and drop_index(). Detect the
      # index's presence in signature() and drill(), and act accordingly.
      #
      # N.B. Facet instances can assume they have been mixed in with an ActiveRecord::Relation and
      #      Repertoire::Faceting::Model (see the mixin() method below). Think of them as scoped
      #      relations that identify an attribute of the model dataset.
      #
      # See BasicFacet and NestedFacet for examples of facet implementations.
      #
      module AbstractFacet

        attr_accessor :facet_name

        # Return true if this facet implementation can index this ActiveRecord relation.  If multiple
        # implementations claim a facet, the one that is laoded last wins.
        def self.claim?(relation)
          raise "Please implement claim? for your facet"
        end

        # Return an arel expression for the signature of all models matching the given current refinement state for
        # this facet (and ignoring all others). Signatures should be constructed from the column returned by
        # faceting_id().
        def signature(state)
          raise "Please implement signature for your facet"
        end

        # Return an arel expression for (state, signature) pairs from which one can refine the current state of this facet
        # (ignoring all others). Signatures should be constructed from the column returned by faceting_id().
        def drill(state)
          raise "Please implement drill for your facet"
        end

        # Create this facet's index table, or raise an exception if indexing not supported. Signatures should be
        # constructed from the column returned by faceting_id().
        def create_index
          raise "Facet #{facet_name} does not support indexing"
        end
        
        # Refresh this facet's index, or raise an exception if it is not indexed
        def refresh_index
          raise "Facet #{facet_name} is not indexed" unless facet_indexed?
          connection.refresh_materialized_view(facet_index_name)
        end
        
        # Drop this facet's index, or raise an exception if it is not indexed
        def drop_index
          raise "Facet #{facet_name} is not indexed" unless facet_indexed?
          connection.drop_materialized_view(facet_index_name)
        end

        # Returns true if the facet's index table exists
        def facet_indexed?
          indexed_facets.map(&:to_sym).include?(facet_name)
        end

        protected

        # Return a facet's index table name
        def facet_index_name
          connection.facet_table_name(table_name, facet_name)
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