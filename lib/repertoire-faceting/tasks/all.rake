require 'pathname'

namespace :db do
  namespace :faceting do

    desc "Build and install PostgreSQL native bitset as shared library"
    task :build do
      system "cd #{Repertoire::Faceting::MODULE_PATH}/ext; make; sudo make install"
    end
    
  end
end