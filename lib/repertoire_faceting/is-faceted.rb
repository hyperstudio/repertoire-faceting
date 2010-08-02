require 'pathname'

require Pathname(__FILE__).dirname.expand_path / 'is-faceted' / 'is' / 'faceted.rb'

DataMapper::Model.append_extensions DataMapper::Is::Faceted

# Include the plugin in Resource
module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::Faceted
    end # module ClassMethods
  end # module Resource
end # module DataMapper
