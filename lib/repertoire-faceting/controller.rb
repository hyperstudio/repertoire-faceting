module Repertoire
  module Faceting #:nodoc:
    
    # Include this mixin in your controller to add faceting webservices for use with the javascript
    # widgets.  Implementors should over-ride base() to specify the model for the faceted browser.
    #
    #   class PaintingsController
    #     include Repertoire::Faceting::Controller
    #     def base
    #       Painting
    #     end
    #   end
    #
    # By default two web services are defined, one for the facet value count widgets and another for
    # the result widget.  Each builds on the model returned by base():
    #
    #   counts  ==> base.refine(params[:filter]).count(params[:facet])
    #   results ==> base.refine(params[:filter]).to_a
    #
    # If desired, you can use the Model API to specify a query that limits the faceting context to
    # a subset of the available items from the start:
    #
    #     def base
    #       q = "#{params[:search]}%"
    #       Painting.where(["title like ?", q])
    #     end
    #
    # Finally, you are free to over-ride the counts() and results() webservices.  Here we 
    # reorder the facet value counts depending on another webservice param:
    #
    #     def counts
    #       facet   = params[:facet]
    #       filter  = params[:filter] || {}
    #       sorting = case params[:order]
    #                   when 'alphanumeric' then ["#{facet} ASC"]
    #                   when 'count'        then ["count DESC", "#{facet} ASC"]
    #                 end
    #       @counts = base.refine(filter).order(sorting).count(facet)
    #       render :json => @counts.to_a
    #     end
    #
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
      
      # Over-ride in your controller to specify the base model for facet counts and results.
      def base
        raise "Override the base() method in your controller to define the faceting model/context"
      end
      
    end
  end
end