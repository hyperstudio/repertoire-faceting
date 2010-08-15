require 'rails'

module Repertoire
  module Faceting
    class Railtie < Rails::Railtie
      config.repertoire_faceting = ActiveSupport::OrderedOptions.new
      
      initializer "repertoire_faceting.relation_extensions" do
        ActiveSupport.on_load(:active_relation) do
# TODO.  unclear how this works...           
#            include Repertoire::Faceting::Calculations
        end
      end
      
      initializer "repertoire_faceting.check_indexes" do
        # TODO.  check which facets have in-database indexes here
      end
      
      rake_tasks do
        dir = Pathname(__FILE__).dirname.expand_path
        load dir + "tasks.rake"
      end
      
    end
  end
end