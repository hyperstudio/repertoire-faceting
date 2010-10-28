ActiveRecord::Schema.define do
  
  %w(affiliations nobelists).each do |table_name|
    execute "DROP TABLE  IF EXISTS #{quote_table_name table_name}"
  end
  
  create_table :nobelists do |t|
    t.text     :name,         :null => false
    t.datetime :birthdate
    t.datetime :deathdate
    t.text     :birth_country
    t.text     :birth_state
    t.text     :birth_city
    t.text     :url
    t.text     :discipline
    t.boolean  :shared,       :default => false
    t.text     :last_name,    :null => false
    t.integer  :nobel_year,   :null => false
    t.boolean  :deceased
    t.text     :co_winner
    t.text     :image_url
    t.text     :image_credit
  end

  create_table :affiliations do |t|
    t.integer  :nobelist_id
    t.text     :detail,       :null => false
    t.text     :degree
    t.integer  :year
  end
  
end