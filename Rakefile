require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'merb-core/version'
require 'merb-core/tasks/merb_rake_helper'

NAME = "repertoire_faceting"
GEM_VERSION = "0.3.1"
AUTHOR = "Christopher York"
EMAIL = "yorkc@mit.edu"
HOMEPAGE = "http://hyperstudio.mit.edu/"
SUMMARY = "Merb plugin that provides faceted indexing and browsing"

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'merb'
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb', '>= 0.9.4')
  s.add_dependency('datamapper', '>= 0.9.4')
  s.require_path = 'lib'
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{ext,lib,spec<%= bin ? ',bin' : '' %>}/**/*")
  s.platform        = Gem::Platform::RUBY
  s.extensions      =  %w[ ext/extconf.rb ]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the plugin locally"
task :install => [:package] do
  sh %{#{sudo} gem install #{install_home} pkg/#{NAME}-#{GEM_VERSION} --no-update-sources}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{#{sudo} jruby -S gem install #{install_home} pkg/#{NAME}-#{GEM_VERSION}.gem --no-rdoc --no-ri}
  end

end
