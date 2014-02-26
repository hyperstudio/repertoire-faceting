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
  s.description = "Repertoire-faceting adds scalable facet indexing, ajax facet widgets, and extras like GIS facets to Rails 3 & 4"

  s.required_ruby_version = ">= 2.0.0"

  s.required_rubygems_version = ">= 1.3.7"
  s.rubyforge_project         = "repertoire-faceting"

  s.files        = Dir.glob("{ext,lib,vendor}/**/*") + %w(FAQ INSTALL LICENSE README TODO)
  s.require_path = 'lib'

  s.add_dependency('rails', '>=3.2.11', '<4.1')
  s.add_dependency('jquery-rails')
  s.add_dependency('pg', '>=0.11', '<0.18')

  s.post_install_message = <<-POST_INSTALL_MESSAGE
  #{'*'*80}
  If this is the first time you have installed Repertoire faceting, you need
  to build and install the native PostgreSQL extension:

    cd <my-rails-app>
    rake db:faceting:extensions:install

  See the repertoire-faceting README for details.
  #{'*'*80}
  POST_INSTALL_MESSAGE
end