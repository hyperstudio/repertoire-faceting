module DataMapper
  module FacetingMethods
    
    # TODO.  factor out common parts of facet_count and facet_result
    
    def facet_count(*args)
      query = args.last.kind_of?(Hash) ? args.pop : {}
      facet = args.first

      raise "Property #{facet} must be declared as a facet" unless self.facet?(facet)

      adapter = query.repository.adapter
      
      refinements = query.delete(:refinements) || query.only(*@facets.keys)
      query.delete_if { |k, v| facet?(k) }
      order       = query.delete(:order) || [:count.desc]
      
      base = base(query)
      filter = filter(adapter, refinements)

      adapter.facet_count(storage_name, facet, base, filter, order)
    end

    def facet_result(*args)
      query = args.last.kind_of?(Hash) ? args.pop : {}

      adapter = query.repository.adapter
      
      refinements = query.delete(:refinements) || query.only(*@facets.keys)
      query.delete_if { |k, v| facet?(k) }
      order       = query.delete(:order)
      
      base = base(query)
      
      puts "OK. refinements are #{refinements}"
      
      filter = filter(adapter, refinements)
      
      adapter.de_signature(self, base, filter, order)
    end
    
    private
    def base(query)
      adapter = query.repository.adapter

      # (2) run the query with the ordinary columns.  this is the base signature (as a string)
      query[:fields] = [:id]
      query[:order] = [:id]
      adapter.signature(scoped_query(query), 'id', '_packed_id')
    end
    
    # (3) run a signature filter query with the facet columns, returning bitset as string
    def filter(adapter, refinements)
      refinements.empty? ? nil : adapter.filter(storage_name, refinements)
    end
  end
end
