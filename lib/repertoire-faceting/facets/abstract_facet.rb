module Repertoire
  module Faceting
    module AbstractFacet
      extend ActiveSupport::Concern
      
      # Implement at least self.claim?() and drill() to create a working facet
      # To add indexing, add index() and drill_indexed()
      
      # Return true if this implementation can index this facet      
      def self.claim?(relation, opts={})
        raise 'Please implement claim? for your facet'
      end
      
      # Return an arel expression for the signature of all models matching the given current refinement state for
      # this facet (and ignoring all others).  if combine is specified, only a signature covering all existing facet 
      # value options is produced.
      def drill(state, combine)
        raise 'Please implement drill for your facet'
      end
      
      # Identical to drill, but using the facet's index table
      def drill_indexed(state, combine)
        raise 'This facet does not support indexing'
      end

      # Return an arel expression for this facet's index table, or raise an exception if indexing not supported
      def index
        raise 'This facet does not support indexing'
      end
      
      protected

      # Return the facet's index table name
      def facet_index_table
        connection.facet_table_name(@klass.table_name, facet_name_value)
      end

      def facet_column(name=nil)
        name || group_values.first
      end
      
    end
  end
end