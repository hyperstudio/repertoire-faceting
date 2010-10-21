lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'repertoire-faceting/version'
 
Gem::Specification.new do |s|
  s.name        = "repertoire-faceting"
  s.version     = Repertoire::Faceting::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher York"]
  s.email       = ["yorkc@mit.edu"]
  s.homepage    = "http://github.com/repertoire/repertoire-faceting"
  s.summary     = "Rails/Postgresql plugin for faceted indexing and browsing"
  s.description = "Repertoire-faceting adds scalable facet indexing, ajax facet widgets, and extras like GIS facets to Rails 3"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "repertoire-faceting"
 
  s.files        = Dir.glob("{ext,lib,public}/**/*") + %w(FAQ LICENSE README TODO)
  s.require_path = 'lib'
  
  s.add_dependency('repertoire-assets', '~> 0.2.0')
  s.add_dependency('rep.jquery', '~>1.3.2')
  s.add_dependency('rep.ajax.toolkit', '~>0.3.0')
  
  s.add_dependency('rails', '~>3.1.0')
  s.add_dependency('pg', '~>0.9.0')
  
  s.post_install_message = <<-POST_INSTALL_MESSAGE
  #{'*'*80}
  If this is the first time you have installed Repertoire faceting, you need
  to build and install the native PostgreSQL extension:

    cd <my-rails-app>
    rake faceting:postgres:install

  See the repertoire-faceting README for details.
  #{'*'*80}
  POST_INSTALL_MESSAGE
end