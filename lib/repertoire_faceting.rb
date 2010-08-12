require 'pathname'

# require code that must be loaded before the application
dir = Pathname(__FILE__).dirname.expand_path + 'repertoire_faceting'

require dir + 'calculations'
require dir + 'model'
require dir + 'relation'
require dir + 'version'

#require dir + 'adapters' + 'postgres_adapter'
