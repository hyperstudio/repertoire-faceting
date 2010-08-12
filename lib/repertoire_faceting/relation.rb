require 'active_record/relation'

module ActiveRecord
  class Relation
    include Repertoire::Faceting::Calculations
  end
end