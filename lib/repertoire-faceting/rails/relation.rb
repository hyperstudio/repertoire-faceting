require 'active_record/relation'

module ActiveRecord
  class Relation
    include Repertoire::Faceting::Relation::Calculations
    include Repertoire::Faceting::Relation::QueryMethods
    include Repertoire::Faceting::Relation::SpawnMethods
  end
end