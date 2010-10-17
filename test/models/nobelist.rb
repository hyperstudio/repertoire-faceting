require 'models/affiliation.rb'

class Nobelist < ActiveRecord::Base
  include Repertoire::Faceting::Model

  # see 'repertoire-faceting/test/nobelists.sql'

  has_many :affiliations

  facet :discipline
  facet :nobel_year
  facet :degree, joins(:affiliations).group('affiliations.degree')
  facet :birth_place, group(:birth_country, :birth_state, :birth_city)
  facet :birthdate, group("EXTRACT (year FROM birthdate)", "trim(to_char(birthdate, 'Month'))", "EXTRACT (day FROM birthdate)")
  
end