module Repertoire
  module Faceting
    module Controller
      extend ActiveSupport::Concern
      
      def counts
        facet  = params[:facet]
        filter = params[:filter] || {}
        
        puts "Counting #{facet}; base is #{base.to_sql}"
        
        @counts = base.refine(filter).count(facet)

        render :json => @counts.to_a
      end

      def results
        filter = params[:filter] || {}

        @results = base.refine(filter).to_a
        
        respond_to do |format|
          format.html { render @results, :layout => false }
          format.json { render :json => @results }
        end
      end
      
      protected
      
      def base
        raise "Override the base() method in your controller to define the faceting model/context"
      end
      
    end
  end
end