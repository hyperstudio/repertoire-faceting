require 'pathname'

namespace :faceting do

  namespace :postgres do
    dir = Pathname(__FILE__).dirname.expand_path + '../../ext'

    desc "Build and install PostgreSQL native bitset type"
    task :install => :build do
      system "cd #{dir}; sudo make install"
    end
    
    task :build do
      system "cd #{dir}; sudo make"
    end
    
  end
  
end
