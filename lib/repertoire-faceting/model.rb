module Repertoire
  module Faceting
    module Model #:nodoc:
      extend ActiveSupport::Concern
      
      SIGNATURE_WASTAGE_THRESHOLD = 0.15
      DEFAULT_SIGNATURE_COLUMN    = 'id'
      PACKED_SIGNATURE_COLUMN     = '_packed_id'
      
      included do |base|
        base.singleton_class.delegate :refine, :minimum, :nils, :reorder, :to_sql, :to => :scoped
      end
      
      #
      # == Facet declarations
      #
      # Facet declarations consist of a facet name and an optional ActiveRecord relation that describes
      # the attribute column to facet over, any joins necessary to reach it, and other defaults. They
      # work similarly to Rails scoped queries.  For example:
      #
      #   class Nobelist < ActiveRecord::Base
      #     include Repertoire::Faceting::Model
      #     has_many :affiliations
      #
      #     facet :discipline
      #     facet :degree,     joins(:affiliations).group('affiliations.degree')
      #     facet :birthdate,  order('birthdate ASC')
      #   end
      #
      # Implicitly, any facet declaration is an SQL aggregate that divides the attribute values into discrete
      # groups.  When no relation is provided, /model/.group(/facet name/) is assumed by default.  So the 
      # discipline facet declaration above is equivalent to
      #
      #   facet :discipline, group(:discipline)
      #
      # and the grouping on degree could be left out.  You can use this behavior to construct a facet 
      # from differently-named columns:
      #
      #   facet :balloon_color, group(:color)
      #
      # or to synthesize values using an SQL expression:
      #
      #   facet :birth_year, group('EXTRACT(year FROM birthdate)')
      #
      # As shown above, facets can be constructed from an arbitrary set of joined tables.
      #
      # == Nested facets
      #
      # Facets can be built from a nested hierarchy of values by providing multiple group columns.  In this
      # case, value counts are aggregated at each level in turn.
      #
      #   facet :birth_place, group(:birth_country, :birth_state, :birth_city)
      #
      # As for basic facets, nested facets may consist of SQL expressions.  This is particularly useful in
      # faceting over data in more complex types such as dates or geographical regions:
      #
      #   facet :birth_date, group('EXTRACT(year FROM birthdate)', 'EXTRACT(month FROM birthdate)', 'EXTRACT(day FROM birthdate)')
      #
      # == Facet options
      #
      # The following query options can also be specified in the facet declaration.
      #
      # [order] Order for facet value counts.  Two computed columns are available, "count" and another with the
      #         facet's name.  For example, to order a genre facet alphanumerically within each descending count:
      #           facet :genre, order('count DESC', 'genre ASC')
      #
      # [nils] Whether to include null facet values in the results or not.  Defaults to true:
      #          facet :genre, nils(false)
      #
      # [minimum] Cut-off below which facet value counts should not be listed:
      #             facet :genre, minimum(5)
      #
      # == Executing Queries
      #
      # Facet value count and result queries follow the format familiar from ActiveRecord group and count
      # aggregation.  This allows you to execute a facet value count query given a base set of records.
      #
      #   Nobelist.where("name LIKE 'Robert%").count(:discipline)
      #
      # To incorporate refinements on other facets on this model, use refine:
      #
      #   Nobelist.refine(:nobel_year => 2001, :degree => 'Ph.D.').count(:discipline)
      # 
      # If you provide multiple values for a simple facet refinement, they are interpreted as a logical "or":
      #
      #   Nobelist.refine(:nobel_year => [2000, 2001])     # => 'WHERE name IN (2000, 2001)'
      #
      # In the case of a nested facet, multiple values identify levels in the taxonomy:
      # 
      #   Nobelist.refine(:birth_place => [ 'Ukraine', 'Kiev' ]).count(:nobel_year)
      #
      # Refinements are integrated into result queries automatically:
      #
      #   Nobelist.refine(:birth_place => [ 'Ukraine', 'Kiev' ]).all
      #
      # == Index access
      #
      # As you will have noted already, facet counts and queries are quite similar to their ActiveRecord/SQL
      # counterparts.  Behind the scenes, the Repertoire faceting code re-writes your query.  
      #
      # Facets defined on associations are joined and limited automatically, and facet indices in the database 
      # are used wherever possible rather than querying the model table.
      #
      # == Facet registration
      #
      # The system supports plugins for new facet type implementations.  When a new facet is declared, the
      # available facet implementations are polled until one claims the new relation.  For example, of the
      # built-in facet implementations, BasicFacet claims facets with a single group column, and NestedFacet
      # claims those with several group columns.  If several facet implementations claim a facet, the one
      # that registered later wins.
      #
      # See AbstractFacet for more details.
      #
      module ClassMethods
        
        # Declare a facet by name
        def facet(name, rel=nil)
          name = name.to_sym

          # default: group by column with facet name, order by count descending
          rel ||= scoped
          rel = rel.group(name)                           if rel.group_values.empty?
          rel = rel.order(["count DESC", "#{name} ASC"])  if rel.order_values.empty?

          # locate facet implementation that can handle relation
          facets[name] = Facets::AbstractFacet.mixin(name, rel)
        end
        
        # Accessor for the facet definitions
        def facets
          read_inheritable_attribute(:facets) || write_inheritable_attribute(:facets, {})
        end
        
        # Is there a facet by this name?
        def facet?(name)
          facets.key?(name.to_sym)
        end
        
        # All defined facets by name
        def facet_names
          facets.keys
        end
        
        # Drops any unused facet indices, updates its packed ids, then recreates 
        # indices for the facets with the provided names.  If no names are provided, 
        # then the existing facet indices are refreshed.
        #
        # If a signature id column name is provided, it will be used to build the 
        # bitset indices. Otherwise the indexer will add or remove a new packed 
        # id column as appropriate.
        #
        # Examples:
        #
        # === Refresh existing facet indices
        #
        #   Nobelist.update_indexed_facets
        #
        # === Adjust which facets are indexed
        #
        #   Nobelist.update_indexed_facets([:degree, :nobel_year])
        #
        # === Drop all facet indices, but add/remove packed id as necessary
        #
        #   Nobelist.update_indexed_facets([])
        #
        # === Drop absolutely everything, force manual faceting using 'id' 
        #     column
        #
        #   Nobelist.udpate_indexed_facets([], 'id')
        #
        def update_indexed_facets(facet_names=nil, signature_column=nil)
          # default: update existing facets
          indexed_facets = connection.indexed_facets(table_name)
          facet_names ||= indexed_facets
          
          # determine best column for signature bitsets, unless set manually
          signature_column ||= if signature_wastage('id') < SIGNATURE_WASTAGE_THRESHOLD
            DEFAULT_SIGNATURE_COLUMN
          else
            PACKED_SIGNATURE_COLUMN
          end
          
          connection.transaction do
            # drop old facet indices
            indexed_facets.each do |name|
              table = connection.facet_table_name(table_name, name)
              connection.drop_table(table)
            end
            
            # create or remove packed signature column as necessary
            ensure_numbering(signature_column)

            # re-create the facet indices
            facet_names.each do |name|
              name = name.to_sym
              raise "Unknown facet #{name}" unless facet?(name)
              facets[name].create_index(signature_column)
            end
          end
          
          reset_column_information
        end
        
        # Returns the name of the id column to use for constructing bitset signatures
        # over this model.
        def faceting_id
          [PACKED_SIGNATURE_COLUMN, DEFAULT_SIGNATURE_COLUMN].detect { |c| column_names.include?(c) }
        end
        
        def signature_wastage(col=nil)
          col ||= faceting_id
          connection.signature_wastage(table_name, col)
        end
        
        def ensure_numbering(signature_column)
          if signature_column == DEFAULT_SIGNATURE_COLUMN
            connection.remove_column(table_name, PACKED_SIGNATURE_COLUMN) if column_names.include?(PACKED_SIGNATURE_COLUMN)
          else
            connection.renumber_table(table_name, PACKED_SIGNATURE_COLUMN, SIGNATURE_WASTAGE_THRESHOLD)
          end
        end
        
      end
    end
  end
end