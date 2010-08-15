module Repertoire
  module Faceting
    class InstallGenerator < Rails::Generators::Base  
      source_root File.expand_path("../templates", __FILE__)
      
      def copy_initializer
        template "repertoire_faceting.rb", "config/initializers/repertoire_faceting.rb"
      end
      
    end
  end
end