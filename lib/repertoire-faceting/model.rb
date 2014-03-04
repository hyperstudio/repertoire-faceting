module Repertoire
  module Faceting
    module Model #:nodoc:
      extend ActiveSupport::Concern

      SIGNATURE_WASTAGE_THRESHOLD = 0.15
      DEFAULT_SIGNATURE_COLUMN    = 'id'
      PACKED_SIGNATURE_COLUMN     = '_packed_id'

      included do |base|
        base.singleton_class.delegate :refine, :minimum, :nils, :reorder, :to_sql, :to => :scoped_all

        base.class_attribute(:facets)
        base.facets = {}
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
          rel ||= scoped_all
          rel = rel.group(name)                           if rel.group_values.empty?
          rel = rel.order(["count DESC", "#{name} ASC"])  if rel.order_values.empty?

          # locate facet implementation that can handle relation
          facets[name] = Facets::AbstractFacet.mixin(name, rel)
        end

        # Is there a facet by this name?
        def facet?(name)
          facets.key?(name.to_sym)
        end

        # All defined facets by name
        def facet_names
          facets.keys
        end

        # Returns a list of the facets that currently have indices declared
        def indexed_facets
          connection.indexed_facets(table_name)
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
        #   Nobelist.index_facets
        #
        # === Adjust which facets are indexed
        #
        #   Nobelist.index_facets([:degree, :nobel_year])
        #
        # === Drop all facet indices, but add/remove packed id as necessary
        #
        #   Nobelist.index_facets([])
        #
        # === Drop absolutely everything, force manual faceting using 'id'
        #     column
        #
        #   Nobelist.index_facets([], 'id')
        #
        def index_facets(next_indexes=nil, next_faceting_id=nil)
          # default: update existing facets
          current_indexes = indexed_facets
          next_indexes ||= current_indexes

          # sanity checks
          current_indexes = current_indexes.map { |name| name.to_sym }
          next_indexes    = next_indexes.map    { |name| name.to_sym }
          (current_indexes | next_indexes).each do
            |name| raise QueryError, "Unknown facet #{name}" unless facet?(name)
          end

          # determine best column for signature bitsets, unless set manually
          next_faceting_id ||= if signature_wastage(DEFAULT_SIGNATURE_COLUMN) < SIGNATURE_WASTAGE_THRESHOLD
            DEFAULT_SIGNATURE_COLUMN
          else
            PACKED_SIGNATURE_COLUMN
          end

          # default behavior: no changes to packed id column
          drop_packed_id = create_packed_id = false

          # default behavior: adjust facet indexes
          drop_list    = current_indexes - next_indexes
          refresh_list = next_indexes & current_indexes
          create_list  = next_indexes - current_indexes

          # adding or removing a packed id column
          if next_faceting_id != faceting_id
            drop_packed_id   = (next_faceting_id == DEFAULT_SIGNATURE_COLUMN)
            create_packed_id = (next_faceting_id != DEFAULT_SIGNATURE_COLUMN)
          end

          # special case: repacking an existing packed id column
          if next_faceting_id == faceting_id && next_faceting_id != DEFAULT_SIGNATURE_COLUMN
            drop_packed_id = create_packed_id = (signature_wastage > SIGNATURE_WASTAGE_THRESHOLD)
          end

          # changing item ids invalidates all existing facet indices
          if drop_packed_id || create_packed_id
            drop_list, refresh_list, create_list = [ current_indexes, [], next_indexes ]
          end

          connection.transaction do
            # adjust faceting id column
            connection.remove_column(table_name, PACKED_SIGNATURE_COLUMN)           if drop_packed_id
            connection.add_column(table_name, PACKED_SIGNATURE_COLUMN, "SERIAL")    if create_packed_id
            @faceting_id = next_faceting_id

            # adjust facet indices
            drop_list.each    { |name| facets[name].drop_index }
            refresh_list.each { |name| facets[name].refresh_index }
            create_list.each  { |name| facets[name].create_index }
          end

          # TODO. in a nested transaction, this would need to fire after the final commit...
          reset_column_information

        end

        # Over-rides reset_column_information in ActiveRecord::ModelSchema
        def reset_column_information
          @faceting_id = nil
          super
        end

        # Returns the name of the id column to use for constructing bitset signatures
        # over this model.
        def faceting_id
          @faceting_id ||= [PACKED_SIGNATURE_COLUMN, DEFAULT_SIGNATURE_COLUMN].detect { |c| column_names.include?(c) }
        end

        # Returns the proportion of wasted slots in 0..max(id)
        def signature_wastage(signature_column = nil)
          signature_column ||= faceting_id
          connection.signature_wastage(table_name, signature_column)
        end

        # Once clients have migrated to Rails 4, delete and replace with 'all' where this is called
        #
        # c.f. http://stackoverflow.com/questions/18198963/with-rails-4-model-scoped-is-deprecated-but-model-all-cant-replace-it
        def scoped_all
          where(nil)
        end

      end
    end
  end
end