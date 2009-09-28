module Repertoire
  module Faceting
    module Query
      def self.included(base)
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          alias update_without_refinements update
          alias update update_with_refinements
          
          alias relative_without_refinements relative
          alias relative relative_with_refinements
        RUBY
      end
      
      # storage for refinements
      
      attr_accessor :refinements
      
      # wrappers for copying queries
      
      def update_with_refinements(other)
        update_without_refinements(other)
        
        if other.respond_to?(:refinements)
          merge_refinements(other.refinements)
        end
        
        self
      end
      
      def relative_with_refinements(options)
        relative_query = relative_without_refinements(options)
        relative_query.merge_refinements(self.refinements) unless self.refinements.nil?
        relative_query
      end
      
      # helper methods
      
      def merge_refinements(other)
        self.refinements ||= Mash.new
        other.each_pair do |facet, values|
          self.refinements[facet] ||= []
          self.refinements[facet] |= [values.dup].flatten
        end
        
        self
      end
      
    end
  end
end
