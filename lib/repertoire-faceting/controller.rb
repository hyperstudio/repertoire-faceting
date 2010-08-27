module Repertoire
  module Faceting
    module Controller
      extend ActiveSupport::Concern
      
      def counts
        name   = params[:facet]
        filter = params[:filter] || {}
        order  = params[:order] || :count
        
        base = base(name).refine(filter)
        
        # TODO.  better support for ordering
        case order.to_sym
        when :count
          base = base.reorder("count desc")
        end
        
        @counts = base.count

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