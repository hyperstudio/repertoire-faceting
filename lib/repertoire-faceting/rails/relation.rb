require 'active_support/core_ext'
require 'active_record/relation'

module ActiveRecord
  class Relation
    include Repertoire::Faceting::Relation::QueryMethods
    include Repertoire::Faceting::Relation::SpawnMethods
    include Repertoire::Faceting::Relation::Calculations
  end
end