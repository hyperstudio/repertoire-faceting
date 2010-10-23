module Repertoire
  module Faceting
    
    # Include this module in your controller to add faceting webservices.
    module Controller
      
      # Web-service to return value, count pairs for a given facet, given existing filter refinements
      # on other facets in the context.  Over-ride this method if you need to specify additional 
      # query params for faceting.
      def counts
        facet  = params[:facet]
        filter = params[:filter] || {}
        raise "Unkown facet #{facet}" unless base.facet?(facet)
        
        @counts = base.refine(filter).count(facet)

        render :json => @counts.to_a
      end

      # Web-service to return the results of a query, given existing filter requirements.  Over-ride
      # this method if you need to specify additional query parms for faceting results.
      def results
        filter = params[:filter] || {}

        @results = base.refine(filter).to_a
        
        respond_to do |format|
          format.html { render @results, :layout => false }
          format.json { render :json => @results }
        end
      end
      
      protected
      
      # Over-ride the base method in your controller to specify the base model for facet counts and results.
      def base
        raise "Override the base() method in your controller to define the faceting model/context"
      end
      
    end
  end
end