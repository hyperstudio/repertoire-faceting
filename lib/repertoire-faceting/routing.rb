module Repertoire
  module Faceting #:nodoc:
    #
    # Standard routing extensions for Repertoire Faceting webservices.
    #
    #   Example::Application.routes.draw do
    #     faceting_for :paintings
    #   end
    #
    # N.B. Include faceting routes before any resources!
    #
    module Routing
      
      #
      # Add routes for the faceting webservices provided by the Controller mixin.
      #
      def faceting_for(*controllers)
        controllers.map!(&:to_sym)
        controllers.each do |ctlr|
            get "/#{ctlr}/counts/:facet", :controller => ctlr, :action => 'counts'
            get "/#{ctlr}/results",       :controller => ctlr, :action => 'results'
        end
      end
        
    end
  end
end
