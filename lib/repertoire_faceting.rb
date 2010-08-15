require 'pathname'

# require code that must be loaded before the application
dir = Pathname(__FILE__).dirname.expand_path + 'repertoire_faceting'

require dir + 'calculations'
require dir + 'controller'
require dir + 'model'
require dir + 'version'

require dir + 'railtie'
require dir + 'rails/relation'
require dir + 'rails/routes'

#require dir + 'adapters' + 'postgres_adapter'
