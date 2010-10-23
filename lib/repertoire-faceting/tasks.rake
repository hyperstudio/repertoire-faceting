require 'pathname'

namespace :faceting do

  namespace :postgres do
    dir = Pathname(__FILE__).dirname.expand_path + '../../ext'

    desc "Load bitset functions into a specific database"
    task :load => :install do
      puts "\nDatabase name?"
      db_name = $stdin.gets.chomp
      sharedir = `pg_config --sharedir`.chomp
      system "psql -Upostgres -f #{sharedir}/contrib/signature.sql #{db_name}"
    end
    
    desc "Build and install PostgreSQL native bitset type"
    task :install => :build do
      puts "Installing native extensions..."
      system "cd #{dir}; sudo make install"
    end
    
    task :build do
      puts "Building native extensions..."
      system "cd #{dir}; sudo make"
    end
    
  end
  
end
