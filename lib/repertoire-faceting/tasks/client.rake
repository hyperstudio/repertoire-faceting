require 'pathname'

namespace :db do
  namespace :faceting do
    
=begin
    API_BINDINGS2 = Dir[Repertoire::Faceting::MODULE_PATH + '/ext/*'].join(", ")
    puts API_BINDINGS2
    
    API_BINDINGS = { :signature => 'faceting',
                     :varbit    => 'faceting_varbit',
                     :bytea     => 'faceting_bytea' }

    desc "Load PostgreSQL faceting API [#{API_BINDINGS.keys.join(', ')}]; default #{API_BINDINGS.first.to_s}"
    task :load, [:binding] => :environment do |t, args|
      binding = (args[:binding] || API_BINDINGS.first).to_sym
      ActiveRecord::Base.connection.load_faceting(binding, true)
    end

    desc "Drop PostgreSQL faceting API from current database"
    task :unload => :environment do
      ActiveRecord::Base.connection.unload_faceting
    end
=end

  end
end