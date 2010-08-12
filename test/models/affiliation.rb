class Affiliation < ActiveRecord::Base
  include Repertoire::Faceting::Model
  
  belongs_to :nobelist
end