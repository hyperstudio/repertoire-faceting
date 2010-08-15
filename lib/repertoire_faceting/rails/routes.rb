require 'action_dispatch/routing'

module ActionDispatch::Routing
  class Mapper
    # Include faceting_for method for routes.
    
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
