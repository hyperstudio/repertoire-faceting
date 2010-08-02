require 'merb-core'
require 'merb-core/tasks/merb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "repertoire_faceting"
    s.summary = "Rails/Postgresql plugin that provides faceted indexing and browsing"
    s.description = "Rails/Postgresql plugin that provides faceted indexing and browsing"
    s.email = "yorkc@mit.edu"
    s.homepage = "http://github.com/repertoire/repertoire-faceting"
    s.authors = ["Christopher York"]
    
    s.add_dependency('repertoire-assets', '~>0.1.1')
    s.add_dependency('rep.jquery', '~>1.3.2')
    s.add_dependency('rep.ajax.toolkit', '~>0.2.0')
    
    s.add_dependency('ruby-pg')
    s.add_dependency('rails')
    
    s.extensions = []                         # extensions require sudo access, not possible when bundling - install by hand instead
    
    s.post_install_message = <<-POST_INSTALL_MESSAGE
    #{'*'*80}
    If this is the first time you have installed Repertoire faceting, you need
    to build and install the native PostgreSQL extension.

      cd repertoire-faceting/ext
      sudo make install
      
    To do GIS faceting, you will also need to install the PostGIS spatial extension.
    See the repertoire-faceting README for details.
    #{'*'*80}
    POST_INSTALL_MESSAGE
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "yardoc"
  end
 
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end


begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yardoc)
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end