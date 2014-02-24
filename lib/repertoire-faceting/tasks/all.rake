require 'pathname'

namespace :db do
  namespace :faceting do
    namespace :extensions do

      desc "Build PostgreSQL faceting extensions"
      task :build do
        system "cd #{Repertoire::Faceting::MODULE_PATH}/ext; make"
      end

      desc "Install PostgreSQL faceting extensions in the database"
      task :install => :build do
        system "cd #{Repertoire::Faceting::MODULE_PATH}/ext; sudo make install"
        puts "Load extensions in a migration like so: CREATE EXTENSION faceting"
      end
    end
  end
end