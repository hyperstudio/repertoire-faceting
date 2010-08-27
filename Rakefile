# encoding: UTF-8

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'repertoire-faceting', 'version')

def run_without_aborting(*tasks)
  errors = []

  tasks.each do |task|
    begin
      Rake::Task[task].invoke
    rescue Exception
      errors << task
    end
  end

  abort "Errors running #{errors.join(', ')}" if errors.any?
end

desc 'Default: run tests'
task :default => :test

desc 'Run postgresql and mysql tests'
task :test do
  tasks = %w(test_postgresql test_mysql)
  run_without_aborting(*tasks)
end

%w( postgresql mysql ).each do |adapter|
  Rake::TestTask.new("test_#{adapter}") { |t|
    connection_path = "test/connections/#{adapter}"
    t.libs << "test" << connection_path
    t.test_files = (Dir.glob( "test/cases/**/*_test.rb") + 
                    Dir.glob("test/cases/adapters/#{adapter}/**/*_test.rb")).sort
    t.verbose = true
    t.warning = true
  }
end

desc 'Generate documentation for Repertoire Faceting.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Repertoire Faceting'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('FAQ')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "repertoire-faceting"
    s.version = Repertoire::Faceting::VERSION.dup
    s.summary = "Rails/Postgresql plugin that provides faceted indexing and browsing"
    s.description = "Rails/Postgresql plugin that provides faceted indexing and browsing"
    s.email = "yorkc@mit.edu"
    s.homepage = "http://github.com/repertoire/repertoire-faceting"
    s.authors = ["Christopher York"]
    
    s.add_dependency('repertoire-assets', '>=0.2.0')
    s.add_dependency('rep.ajax.toolkit', '>=0.2.0')
    s.add_dependency('rep.jquery', '>=1.3.2')
    
    s.add_dependency('rails', '>=3.0.0.rc')
    
    s.add_dependency('pg', '>=0.9.0')
    
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
 
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
