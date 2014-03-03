require 'pathname'

namespace :db do
  namespace :faceting do
    namespace :extensions do

      desc "Install PostgreSQL faceting extensions in the database"
      task :install do
        system "cd #{Repertoire::Faceting::MODULE_PATH}/ext; make; sudo make install"
      end
    end
  end
end