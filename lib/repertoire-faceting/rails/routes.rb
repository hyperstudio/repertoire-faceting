require 'action_dispatch/routing'

module ActionDispatch #:nodoc: all
  module Routing
    class Mapper
      # Include faceting_for method for routes.
      include Repertoire::Faceting::Routing
    end
  end
end