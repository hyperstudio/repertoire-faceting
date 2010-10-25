module Repertoire
  module Faceting #:nodoc:
    module Routing
      
      #
      # Add routes for the faceting webservices provided by the Controller mixin.
      #
      #   Example::Application.routes.draw do
      #     faceting_for :nobelists
      #   end
      #
      # N.B. Include faceting routes before any resources!
      #
      def faceting_for(*controllers)
        options = controllers.extract_options!

        controllers.map!(&:to_sym)

        controllers.each do |ctlr|
            match "/#{ctlr}/counts/:facet", :controller => ctlr, :action => 'counts'
            match "/#{ctlr}/results",       :controller => ctlr, :action => 'results'
        end
      end
        
    end
  end
end
    