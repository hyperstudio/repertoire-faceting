require 'pathname'

namespace :db do
  namespace :faceting do
  
    desc "Load PostgreSQL native bitset type into current database"
    task :load => :environment do
      ActiveRecord::Base.connection.load_faceting
    end
    
  end
end