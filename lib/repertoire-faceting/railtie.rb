require 'repertoire-faceting'
require 'rails'

module Repertoire
  module Faceting
    class Railtie < Rails::Railtie #:nodoc:
#      no configuration options necessary
#      config.repertoire_faceting = ActiveSupport::OrderedOptions.new
      
      rake_tasks do
        dir = Pathname(__FILE__).dirname.expand_path
        load dir + "tasks/all.rake"
        load dir + "tasks/client.rake"
      end
      
    end
  end
end