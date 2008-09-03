# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:repertoire_faceting] = {
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    dir = Pathname(__FILE__).dirname.expand_path + 'repertoire_faceting'

    require dir + 'types' + 'array'
    require dir + 'is-faceted'
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  Merb::Plugins.add_rakefiles "repertoire_faceting/merbtasks"
end